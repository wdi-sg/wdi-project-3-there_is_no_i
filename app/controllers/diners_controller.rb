class DinersController < ApplicationController
  include AuthenticateRestaurantUser
  include FindingTableLogic
  include SendTwilio
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :check_user_is_part_of_restaurant
  before_action :set_diner, only: %i[show edit update]
  before_action :set_duration

  def index
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb @restaurant.name, restaurant_path(@restaurant)
    @diners = Reservation.where(restaurant_id: params[:restaurant_id], status: 'dining').or(Reservation.where(restaurant_id: params[:restaurant_id], status: 'awaiting'))
  end

  def edit
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb @restaurant.name, restaurant_path(@restaurant)

    tables_occupied = Reservation.where(restaurant_id: @restaurant.id).where(status: 'dining').where.not(table_id: nil).map do |reservation|
      reservation.table
    end
    all_tables = @restaurant.tables
    tables_avail = all_tables - tables_occupied
    @table_options = tables_avail.map do |table|
      [table.name, table.id]
    end
    # @table_options = @restaurant.tables.where(capacity_current: 0).map do |table|
    #   [table.name, table.id]
    # end
    if @diner.table != nil and @diner.status == 'dining'
      @table_options << [@diner.table.name, @diner.table.id]
    end
    @table_options << ['', nil]
  end

  def show
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb @restaurant.name, restaurant_path(@restaurant)
  end

  def update
    old_party_size = @diner.party_size
    old_table_id = @diner.table_id
    old_start_time = @diner.start_time

#Check if change in table / party size is possible in next status
    if @diner.status == 'queuing' && @diner.table_id == nil && params[:reservation][:status] == 'cancelled'
      @diner.status = params[:reservation][:status]
      save_update(@diner)
######### Diner was QUEUING
    elsif @diner.status == 'queuing'
      if params[:reservation][:status] == 'queuing' or params[:reservation][:status] == 'awaiting'
        set_values(@diner, params[:reservation][:party_size], nil, nil)

        if params[:reservation][:table_id] != '' and params[:reservation][:table_id] != nil

          table = determine_table(@restaurant, [Table.find(params[:reservation][:table_id])], @diner, Time.now, @est_duration)

          if table
            assign_table(@diner, table)

            set_values(@diner, params[:reservation][:party_size], table.id, Time.now)

            @diner.start_time = Time.now
            @diner.end_time = Time.now + @est_duration

            if params[:reservation][:status] == 'awaiting'
              @diner.status = 'awaiting'
              sms_awaiting(@diner)
              save_update(@diner)
            else
              save_update(@diner)
            end

          else
            set_values(@diner, old_party_size, old_table_id, Time.now)

            flash['alert'] = 'New parameters not permitted.'
            tables_occupied = Reservation.where(restaurant_id: @restaurant.id).where(status: 'dining').where.not(table_id: nil).map do |reservation|
              reservation.table
            end
            all_tables = @restaurant.tables
            tables_avail = all_tables - tables_occupied
            @table_options = tables_avail.map do |table|
              [table.name, table.id]
            end
            if @diner.table != nil
              @table_options << [@diner.table.name, @diner.table.id]
            end
            @table_options << ['', nil]
            render :edit
          end
        else
          if old_table_id != nil
            old_table = Table.find(old_table_id)
            if old_table != nil
              old_table.capacity_current = 0
              old_table.save!
            end
          end
          @diner.table = nil
          save_update(@diner)
        end

      elsif params[:reservation][:status] == 'cancelled'
        @diner.status = 'cancelled'
        @diner.end_time = Time.now
        @diner.save
        reassign_table(@diner, @restaurant)
        sms_cancelled(@diner)
        save_update(@diner)
      end

####### Diner was AWAITING or DINING
    elsif @diner.status == 'awaiting' || @diner.status == 'dining'

      if params[:reservation][:status] == 'dining' or params[:reservation][:status] == 'awaiting'
        # @diner.party_size = params[:reservation][:party_size]
        set_values(@diner, params[:reservation][:party_size], nil, nil)

        if params[:reservation][:table_id] != '' and params[:reservation][:table_id] != nil
          table = determine_table(@restaurant, [Table.find(params[:reservation][:table_id])], @diner, Time.now, @est_duration)

          if table

            assign_table(@diner, table)

            set_values(@diner, params[:reservation][:party_size], table.id, Time.now)

            if params[:reservation][:status] == 'dining'
              @diner.status = 'dining'

              save_update(@diner)
            elsif params[:reservation][:status] == 'awaiting'
              @diner.status = 'awaiting'
              save_update(@diner)
            end

          else
            set_values(@diner, old_party_size, old_table_id, Time.now)

            flash['alert'] = 'New parameters not permitted.'
            tables_occupied = Reservation.where(restaurant_id: @restaurant.id).where(status: 'dining').where.not(table_id: nil).map do |reservation|
              reservation.table
            end
            all_tables = @restaurant.tables
            tables_avail = all_tables - tables_occupied
            @table_options = tables_avail.map do |table|
              [table.name, table.id]
            end
            if @diner.table != nil
              @table_options << [@diner.table.name, @diner.table.id]
            end
            @table_options << ['', nil]
            render :edit
          end
        else
          set_values(@diner, params[:reservation][:party_size], params[:reservation][:table_id], Time.now)

          if params[:reservation][:status] == 'dining'
            @diner.status = 'dining'
            save_update(@diner)
          elsif params[:reservation][:status] == 'awaiting'
            @diner.status = 'awaiting'
            save_update(@diner)
          end
        end
      elsif params[:reservation][:status] == 'cancelled' || params[:reservation][:status] == 'queuing' || params[:reservation][:status] == 'checked_out'
        reassign_table(@diner, @restaurant)
        if params[:reservation][:status] == 'cancelled'

          @diner.status = 'cancelled'
          @diner.end_time = Time.now
          @diner.save
          reassign_table(@diner, @restaurant)
          sms_cancelled(@diner)

        elsif params[:reservation][:status] == 'queuing'
          @diner.start_time = nil
          @diner.end_time = nil
          @diner.save
          reassign_table(@diner, @restaurant)
          @diner.status = 'queuing'

          # send to back of queue (requeue)
          @diner.queue_number = @diner.restaurant.next_queue_number
          @diner.restaurant.next_queue_number += 1
          @diner.restaurant.save!
          sms_send_back_queue(@diner)

        elsif params[:reservation][:status] == 'checked_out'
          @diner.status = 'checked_out'
          @diner.end_time = Time.now
          @diner.save
          reassign_table(@diner, @restaurant)
        end
        save_update(@diner)
      end
######## DINER was on RESERVATION (editable status only)
      elsif @diner.status == 'reservation'
        if params[:reservation][:status] == 'reservation'
          save_update(@diner)
        elsif params[:reservation][:status] == 'dining'
          if @diner.table.capacity_current = 0
            @diner.status = 'dining'
            save_update(@diner)
          else
            flash['alert'] = 'The table is currently occupied.'
            tables_occupied = Reservation.where(restaurant_id: @restaurant.id).where(status: 'dining').where.not(table_id: nil).map do |reservation|
              reservation.table
            end
            all_tables = @restaurant.tables
            tables_avail = all_tables - tables_occupied
            @table_options = tables_avail.map do |table|
              [table.name, table.id]
            end
            if @diner.table != nil
              @table_options << [@diner.table.name, @diner.table.id]
            end
            @table_options << ['', nil]
            render :edit
          end
        elsif params[:reservation][:status] == 'cancelled'
          @diner.status = 'cancelled'
          @diner.table_id = nil
          @diner.end_time = nil
          save_update(@diner)
        end
    end
  end

  def reassign_table(diner, restaurant)
    next_customer = find_next_customer(diner.table)
    if next_customer
      # Check if current table has reservations that will clash
      next_customer_table = determine_table(restaurant, [diner.table], next_customer, Time.now, 2.hours)
      if next_customer_table

        assign_table(next_customer, next_customer_table)
        diner.table = nil
        diner.save!
      else
        reset_table_count(diner.table.id) if diner.table
      end
    else
      reset_table_count(diner.table.id) if diner.table
    end
  end

  # Update leaving customer
  def save_update(diner)
    if diner.save!
      flash['notice'] = 'Successfully updated parameters.'
      redirect_to dashboard_path
    else
      flash['alert'] = 'Error 500. Unable to save lastest changes.'
      tables_occupied = Reservation.where(restaurant_id: @restaurant.id).where(status: 'dining').where.not(table_id: nil).map do |reservation|
        reservation.table
      end
      all_tables = @restaurant.tables
      tables_avail = all_tables - tables_occupied
      @table_options = tables_avail.map do |table|
        [table.name, table.id]
      end
      if @diner.table != nil
        @table_options << [@diner.table.name, @diner.table.id]
      end
      @table_options << ['', nil]
      render :edit
    end
  end

  def cancelled
    if Reservation.find(params[:id]) && Restaurant.find(params[:restaurant_id])
      diner = Reservation.find(params[:id])
      diner.status = 'cancelled'
      diner.end_time = Time.now
      diner.save
      reassign_table(diner, @restaurant)
      sms_cancelled(diner)
      flash['alert'] = "#{diner.name}(##{diner.queue_number}) was removed from the queue."
      redirect_to dashboard_path
    else
      flash['alert'] = 'Error. Unable to find reservation or restaurant in DB.'
      redirect_to dashboard_path
    end
  end

  def checked_out
    if Reservation.find(params[:id]) && Restaurant.find(params[:restaurant_id])
      diner = Reservation.find(params[:id])
      diner.status = 'checked_out'
      diner.end_time = Time.now
      diner.save
      reassign_table(diner, @restaurant)
      flash['notice'] = "#{diner.name} was checked out from the restaurant"
      redirect_to dashboard_path
    else
      flash['alert'] = 'Error. Unable to find reservation or restaurant in DB.'
      redirect_to dashboard_path
    end
  end

  private

  def reset_table_count(table_id)
    table = Table.find(table_id)
    table.capacity_current = 0
    table.save!
  end

  def assign_table(customer, table)
    old_table = customer.table
    if old_table != nil
      old_table.capacity_current = 0
      old_table.save!
    end

    customer.table_id = table.id
    customer.start_time = Time.now
    customer.end_time = Time.now + @est_duration
    customer.save!

    new_table = customer.table
    new_table.capacity_current = customer.party_size
    new_table.save!
  end

  def set_values(diner, party_size, table_id, start_time)
    diner.party_size = party_size
    diner.table_id = table_id
    diner.start_time = start_time

    if start_time
      diner.end_time = start_time + @est_duration
    else
      diner.end_time = nil
    end

    diner.save!
  end

  def new_table_count(table, filled)
    table.capacity_current = filled
    table.save!
  end

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_diner
    @diner = Reservation.find(params[:id])
  end

  def diner_params
    params.require(:reservation).permit(:party_size, :special_requests, :status, :table_id)
  end
end
