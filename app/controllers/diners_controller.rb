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

    if params[:reservation][:status] == 'awaiting' || params[:reservation][:status] == 'dining'
      old_start_time = @diner.start_time
      old_table_id = @diner.table_id
      old_party_size = @diner.party_size

      @diner.start_time = nil
      @diner.end_time = nil
      @diner.table_id = params[:reservation][:table_id]
      @diner.party_size = params[:reservation][:party_size]
      @diner.save

      table_if_possible = determine_table(@restaurant, [@diner.table], @diner, Time.now, @est_duration)

      if table_if_possible
        @diner.start_time = Time.now
        @diner.end_time = Time.now + @est_duration
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
      reset_table_count(@diner.table)
      @diner.end_time = Time.now
      @diner.save
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
        sms_awaiting(next_customer)

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
      redirect_to restaurant_diners_path(restaurant)
    else
      flash['alert'] = 'Error. Please check input parameters.'
      render :edit
    end
  end

  private

  def reset_table_count(table)
    table.capacity_current = 0
    table.save!
  end

  def find_next_customer(table)
    # Next Customer must be able to fit into current table
    filtered_queue = Reservation.where('restaurant_id = ?', @restaurant.id).where('status = ?', 'queuing').where('party_size <= ?', table.capacity_total)
    p '====QUEUE where size <= Table===='
    p filtered_queue

    # Next customer must fulfill business criteria (party_size big enough for table's minimum capacity) # allowance 2?

    # If Potential Next Customers can fit, sort by queue_number
    if filtered_queue.count > 1
      sorted_queue = filtered_queue.sort_by { |customer| customer[:queue_number] }
      p '====QUEUE sorted by q num===='
      p sorted_queue
      sorted_queue.each do |queue|
        p queue.queue_number
      end

      next_customer = sorted_queue[0]

    elsif filtered_queue.count == 1
      next_customer = filtered_queue[0]
    else
      next_customer = nil
    end
  end

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
