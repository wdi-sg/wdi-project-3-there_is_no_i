class ReservationsController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!, except: [:create, :new, :show]
  before_action :set_restaurant_id
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]
  before_action :check_user_is_part_of_restaurant, except: [:create, :new, :show]
  helper ReservationsHelper

  def index
    @restaurant_id = params[:restaurant_id]
    if request.fullpath == "/restaurants/#{@restaurant_id}/reservationss?name=sort"
      @reservations = Reservation.where(restaurant_id: params[:restaurant_id]).order(:name)
    elsif request.fullpath == "/restaurants/#{@restaurant_id}/reservations?pax=sort"
      @reservations = Reservation.where(restaurant_id: params[:restaurant_id]).order(:party_size)
    elsif request.fullpath == "/restaurants/#{@restaurant_id}/reservations?date=sort"
      @reservations = Reservation.where(restaurant_id: params[:restaurant_id]).order(:start_time)
    else
      @reservations = Reservation.where(restaurant_id: params[:restaurant_id]).order('start_time ASC')
    end
  end

  def create
    d = Time.parse(params[:reservation][:date])
    date = d.strftime("%Y-%m-%d")
    puts "DATE #{date}"
    day = d.strftime('%d')
    month = d.strftime('%m')
    year = d.strftime('%Y')
    t = Time.parse(params[:reservation][:time])
    r_start_time = t.change(day: day, month: month, year: year, offset: +0o000) + 8.hours
    puts "START TIME: #{r_start_time}"
    r_end_time = r_start_time + 2.hours
    party_size = params[:reservation][:party_size]

    # find all tables (to be refactored into another function)
    # @avail_tables = Table.where(restaurant_id: @restaurant.id).where('capacity_current = ?', 0)
    # find restaurant's tables
    @avail_tables = Table.where(restaurant_id: @restaurant.id)

    # find all reservations from that restaurant on the date chosen by customer on the reservation form
    all_reservations = Reservation.where(restaurant_id: params[:restaurant_id]).where("DATE(start_time) = ?", date)

    # find all reservations that have tables which can be booked
    all_avail_reservations = all_reservations.where("start_time >= ?", r_end_time).or(all_reservations.where("end_time <= ?", r_start_time)).to_a
    puts "ALL RESERVATIONS #{all_avail_reservations}"

    # if-else statement to reject reservation in the event that there are no available tables
    # if all_avail_reservations.length == 0
    #   before_avail_reservations = all_reservations.where("start_time >= ?", r_end_time - 1.hours).or(all_reservations.where("end_time <= ?", r_start_time - 1.hours)).to_a
    #   before_table_array = []
    #   before_avail_reservations.each do |reservation|
    #     before_table_array.push(Table.where("id = ?", reservation.table_id).where("capacity_total >= ?", reservation.party_size))
    #   end
    #   before_table_array.sort_by! { |table| table.capacity_total }
    #   before_chosen_table = before_table_array[0]
    #
    #   after_avail_reservations = all_reservations.where("start_time >= ?", r_end_time + 1.hours).or(all_reservations.where("end_time <= ?", r_start_time + 1.hours)).to_a
    #   after_table_array = []
    #   after_avail_reservations.each do |reservation|
    #     after_table_array.push(Table.where("id = ?", reservation.table_id).where("capacity_total >= ?", reservation.party_size))
    #   end
    #   after_table_array.sort_by! { |table| table.capacity_total }
    #   after_chosen_table = after_table_array[0]
    # else
      # find the tables by table_id in the reservation that have a capacity >= party size
      # table_array = []
      # all_avail_reservations.each do |reservation|
      #   table_array.push(Table.where("id = ?", reservation.table_id).where("capacity_total >= ?", reservation.party_size))
      # end
      #
      # # sort tables in the table array by their capacity_total
      # table_array.sort_by! { |table| table.capacity_total }
      #
      # # [0] of this array will give the table with the minimally adequate capacity to fit all customers
      # the_chosen_table = table_array[0]

      new_res = {}
      new_res[:name] = params[:reservation][:name]
      new_res[:phone] = params[:reservation][:phone]
      new_res[:start_time] = r_start_time
      new_res[:end_time] = r_start_time + 2.hours
      # new_res[:table_id] = the_chosen_table.table_id
      new_res[:party_size] = params[:reservation][:party_size]
      new_res[:restaurant_id] = params[:restaurant_id]

      @reservation = Reservation.new(new_res)

      if @reservation.save
        redirect_to restaurant_path(params[:restaurant_id])
      else
        render :new
      end
    # end
  end

  def edit
  end

  def new
  end

  def show
  end

  def update
    if @reservation.update(reservation_params)
      redirect_to restaurant_reservations_path(@restaurant)
    else
      render :edit
    end
  end

  def destroy
    @reservation.destroy
    redirect_to restaurant_reservations_path(@restaurant)
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:name, :party_size, :start_time)
  end
end
