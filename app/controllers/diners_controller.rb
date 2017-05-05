class DinersController < ApplicationController
  before_action :set_restaurant, only: %i[index show edit update]
  before_action :set_diner, only: %i[show edit update]

  def index
    @diners = Reservation.where(restaurant_id: params[:restaurant_id], status: 'dining').or(Reservation.where(restaurant_id: params[:restaurant_id], status: 'awaiting'))
  end

  def edit; end

  def show; end

  def update
    if params[:reservation][:status] == 'checked_out' || params[:reservation][:status] == 'queuing' || params[:reservation][:status] == 'cancelled'
      table = Table.find(@diner.table_id)
      reset_table_count(table)
      @next_customer = find_next_customer(table)
      assign_table(@next_customer, table) if @next_customer
      save_update(@diner, @restaurant)
    else
      save_update(@diner, @restaurant)
    end
  end

  def save_update(diner, restaurant)
    if diner.update(diner_params)
      redirect_to restaurant_diners_path(restaurant)
    else
      render :edit
    end
  end

  private

  def reset_table_count(table)
    # p '====TABLE that USER LEFT===='
    # p table

    table.capacity_current = 0
    table.save!

    # p '====TABLE Updated===='
    # p table
  end

  def find_next_customer(table)
    filtered_queue = Reservation.where('restaurant_id = ?', @restaurant.id).where('status = ?', 'queuing').where('party_size <= ?', table.capacity_total)

    p '====QUEUE where size <= Table===='
    p filtered_queue

    if filtered_queue.count > 1
      sorted_queue = filtered_queue.sort_by { |customer| customer[:queue_number] }

      # allowance 2
      p '====QUEUE sorted by q num===='
      p sorted_queue
      sorted_queue.each do |queue|
        p queue.queue_number
      end

      sorted_size = sorted_queue.sort_by { |customer| -customer[:party_size] / 2 }

      p '====QUEUE sorted by largest party===='
      p sorted_size
      sorted_size.each do |queue|
        p queue.party_size
      end

      @next_customer = sorted_size[0]

    elsif filtered_queue.count == 1
      @next_customer = filtered_queue[0]
    else
      @next_customer = nil
    end
  end

  def assign_table(next_customer, table)
    next_customer.table_id = table.id
    next_customer.status = 'awaiting'
    next_customer.start_time = Time.now
    next_customer.end_time = Time.now + 2.hours
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
    params.require(:reservation).permit(:party_size, :special_requests, :status)
  end
end
