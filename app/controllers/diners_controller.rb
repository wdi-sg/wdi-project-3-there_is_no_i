class DinersController < ApplicationController
  include FindingTableLogic
  include SendTwilio
  before_action :set_restaurant, only: %i[index show edit update]
  before_action :set_diner, only: %i[show edit update]
  before_action :set_duration, only: [:update, :reassign_table, :assign_table]

  def index
    @diners = Reservation.where(restaurant_id: params[:restaurant_id], status: 'dining').or(Reservation.where(restaurant_id: params[:restaurant_id], status: 'awaiting'))
  end

  def edit
    @table_options = @restaurant.tables.map do |table|
      [table.name, table.id]
    end
  end

  def show; end

  def update
    old_party_size = @diner.party_size
    old_table_id = @diner.table_id
    old_start_time = @diner.start_time

##########
    if @diner.status == 'queuing' && @diner.table_id == nil
      if params[:reservation][:status] == 'queuing'
        @diner.party_size = params[:reservation][:party_size]
        save_update(@diner)
      elsif params[:reservation][:status] == 'cancelled'
        @diner.status = params[:reservation][:status]
        save_update(@diner)
      end
#########
    elsif @diner.status == 'queuing' && @diner.table_id
      # Queuing to Queuing / Awaiting
      if params[:reservation][:status] == 'queuing' or params[:reservation][:status] == 'awaiting'
        # @diner.party_size = params[:reservation][:party_size]
        set_values(@diner, params[:reservation][:party_size], nil, nil)

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
          @table_options = @restaurant.tables.map do |table|
            [table.name, table.id]
          end
          render :edit
        end
        # Queuing to Cancelled
      elsif params[:reservation][:status] == 'cancelled'
        @diner.status = 'cancelled'
        @diner.end_time = Time.now
        @diner.save
        reassign_table(@diner, @restaurant)
        sms_cancelled(@diner)
        save_update(@diner)
      end

#######
    elsif @diner.status == 'awaiting' || @diner.status == 'dining'

      if params[:reservation][:status] == 'dining' or params[:reservation][:status] == 'awaiting'
        # @diner.party_size = params[:reservation][:party_size]
        set_values(@diner, params[:reservation][:party_size], nil, nil)

        table = determine_table(@restaurant, [Table.find(params[:reservation][:table_id])], @diner, Time.now, @est_duration)

        if table

          assign_table(@diner, table)

          set_values(@diner, params[:reservation][:party_size], table.id, Time.now)
          p @diner
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
          @table_options = @restaurant.tables.map do |table|
            [table.name, table.id]
          end
          render :edit
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

          # send to back of queue
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
######## Reservation
      elsif @diner.status == 'reservation'
        if params[:reservation][:status] == 'reservation'
          save_update(@diner)
        elsif params[:reservation][:status] == 'dining'
          if @diner.table.capacity_current = 0
            @diner.status = 'dining'
            save_update(@diner)
          else
            flash['alert'] = 'The table is currently occupied.'
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
      next_customer_table = determine_table(restaurant, [diner.table], next_customer, Time.now, @est_duration)
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
      redirect_to dashboard_path
    else
      flash['alert'] = 'Error 500. Unable to save lastest changes.'
      render :edit
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
