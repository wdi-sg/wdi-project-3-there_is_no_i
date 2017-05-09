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
    # if queuing - NEXTCUSTOMER, CURENTDINER change party_size/ table nil
    # if awaiting - CURENTDINER Check change in table / party_size
    # if dining - CURENTDINER Check change in table / party_size
    # if checked_out - NEXTCUSTOMER, CURENTDINER change status, end time
    # if cancelled - NEXTCUSTOMER, CURENTDINER change status, end time

    if params[:reservation][:status] == 'queuing'
      # if diner was previously queuing, just update their party size
      if @diner.status == 'queuing' && @diner.table == nil
         @diner.party_size = params[:reservation][:party_size]
         save_update(@diner, @restaurant)
       elsif @diner.status == 'queuing'
         p 'TESTESTSEt'
         p @diner.party_size
         p params[:reservation][:party_size]
         if @diner.party_size > params[:reservation][:party_size].to_i
           @diner.party_size = params[:reservation][:party_size]
           save_update(@diner, @restaurant)
         else
           flash['alert'] = 'Error. New parameters are not permitted.'
           redirect_to restaurant_edit_diner_path(@restaurant, @diner)
         end
      else

        if @diner.party_size > params[:reservation][:party_size].to_i
          @diner.party_size = params[:reservation][:party_size]
          save_update(@diner, @restaurant)
        else
          flash['alert'] = 'Error. New parameters are not permitted.'
          redirect_to restaurant_edit_diner_path(@restaurant, @diner)
        end
        
        # if diner was awaiting,
        # Send Customer back to the queue
        @diner.start_time = nil
        @diner.end_time = nil
        @diner.party_size = params[:reservation][:party_size]
        @diner.save

        next_customer = find_next_customer(@diner.table)

        if next_customer
          # Check if current table has reservations that will clash
          next_customer_table = determine_table(@restaurant, [@diner.table], next_customer, Time.now, @est_duration)

          @diner.table_id = nil

          # Send diner to the back of queue
          @diner.queue_number = @diner.restaurant.next_queue_number
          @diner.restaurant.next_queue_number += 1
          @diner.restaurant.save

          sms_send_back_queue(@diner)

          if next_customer_table
            assign_table(next_customer, next_customer_table)
            save_update(@diner, @restaurant)
          else
            save_update(@diner, @restaurant)
          end
        else
          prev_table = @diner.table
          # prev_table.capacity_current = 0
          prev_table.save!

          sms_requeue(@diner)
          save_update(@diner, @restaurant)
        end
      end
    elsif params[:reservation][:status] == 'awaiting' || params[:reservation][:status] == 'dining'
      if @diner.table
        reset_table_count(@diner.table.id)
      end

      old_start_time = @diner.start_time
      old_table_id = @diner.table_id
      old_party_size = @diner.party_size

      @diner.start_time = nil
      @diner.end_time = nil

      if params[:reservation][:table_id] == nil or params[:reservation][:table_id] == ''
        @diner.table_id = old_table_id
      else
        @diner.table_id = params[:reservation][:table_id]
      end

      @diner.party_size = params[:reservation][:party_size]
      @diner.save

      table_if_possible = determine_table(@restaurant, [@diner.table], @diner, Time.now, @est_duration)

      if table_if_possible
        @diner.start_time = Time.now
        @diner.end_time = Time.now + @est_duration

        #update new table count

        new_table = Table.where(id: @diner.table_id)
        p 'TESTSETSETS'
        p new_table
        new_table[0].capacity_current = @diner.party_size
        new_table[0].save!

        save_update(@diner, @restaurant)
      else
        @diner.start_time = old_start_time
        @diner.end_time = old_start_time + @est_duration
        @diner.table_id = old_table_id
        @diner.party_size = old_party_size
        @diner.save
        flash['alert'] = 'Error. New parameters are not permitted.'
        redirect_to restaurant_edit_diner_path(@restaurant, @diner)
        # render :edit
      end
    elsif params[:reservation][:status] == 'checked_out' || params[:reservation][:status] == 'cancelled'

      if @diner.table
        reset_table_count(@diner.table.id)
      end

      @diner.end_time = Time.now
      @diner.save

      if params[:reservation][:status] == 'cancelled'
        sms_cancelled(@diner)
      end

      reassign_table(@diner, @restaurant)

    else
      flash['alert'] = 'Error 500. Check form status.'
      render :edit
    end
  end

  def reassign_table(diner, restaurant)
    next_customer = find_next_customer(diner.table)
    if next_customer
      # Check if current table has reservations that will clash
      next_customer_table = determine_table(restaurant, [diner.table], next_customer, Time.now, @est_duration)
      if next_customer_table

        assign_table(next_customer, next_customer_table)

        # sms_awaiting(next_customer)

        save_update(diner, restaurant)
      else
        save_update(diner, restaurant)
      end
    else
      save_update(diner, restaurant)
    end
  end

  # Update leaving customer
  def save_update(diner, restaurant)
    diner.status = params[:reservation][:status]
    p 'TROUBLESHOOT'
    p diner

    if diner.save!
      redirect_to dashboard_path
      # if diner.status == 'queuing' || diner.status == 'reservation'
      #   redirect_to restaurant_walkins_path(restaurant)
      # else
      #   redirect_to restaurant_diners_path(restaurant)
      # end
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

  # def find_next_customer(table)
  #   # Next Customer must be able to fit into current table
  #   filtered_queue = Reservation.where('restaurant_id = ?', @restaurant.id).where('status = ?', 'queuing').where('party_size <= ?', table.capacity_total)
  #   p '====QUEUE where size <= Table===='
  #   p filtered_queue
  #
  #   # Next customer must fulfill business criteria (party_size big enough for table's minimum capacity) # allowance 2?
  #
  #   # If Potential Next Customers can fit, sort by queue_number
  #   if filtered_queue.count > 1
  #     sorted_queue = filtered_queue.sort_by { |customer| customer[:queue_number] }
  #     p '====QUEUE sorted by q num===='
  #     p sorted_queue
  #     sorted_queue.each do |queue|
  #       p queue.queue_number
  #     end
  #
  #     next_customer = sorted_queue[0]
  #
  #   elsif filtered_queue.count == 1
  #     next_customer = filtered_queue[0]
  #   else
  #     next_customer = nil
  #   end
  # end

  def assign_table(next_customer, table)
    next_customer.table_id = table.id
    next_customer.status = 'queuing'
    next_customer.start_time = Time.now
    next_customer.end_time = Time.now + @est_duration
    next_customer.save!
    new_table_count(table, next_customer.party_size)
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
