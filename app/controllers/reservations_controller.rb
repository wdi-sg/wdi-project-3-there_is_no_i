class ReservationsController < ApplicationController
  include AuthenticateRestaurantUser
  include FindingTableLogic
  before_action :authenticate_user!, except: [:create, :new, :show]
  before_action :set_restaurant_id
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]
  before_action :check_user_is_part_of_restaurant, except: [:create, :new, :show]
  before_action :check_user_is_part_of_reservation, only: [:show]
  helper ReservationsHelper

  def index
    @restaurant_id = params[:restaurant_id]
    if request.fullpath == "/restaurants/#{@restaurant_id}/reservationss?name=sort"
      @reservations = Reservation.where(restaurant_id: params[:restaurant_id]).order('name ASC')
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
    # puts "DATE #{date}"
    day = d.strftime('%d')
    month = d.strftime('%m')
    year = d.strftime('%Y')
    t = Time.parse(params[:reservation][:time])

    r_start_time = t.change(day: day, month: month, year: year, offset: +0o000)
    # puts "START TIME: #{r_start_time}"
    r_end_time = r_start_time + 2.hours
    party_size = params[:reservation][:party_size]

    avail_tables = Table.where(restaurant_id: @restaurant.id)

    # NEED TO VALIDATE PARTY SIZE, date, time
    new_res = Reservation.new()
    new_res[:name] = params[:reservation][:name]
    new_res[:email] = params[:reservation][:email]
    new_res[:phone] = params[:reservation][:phone]
    new_res[:party_size] = params[:reservation][:party_size]
    new_res[:restaurant_id] = params[:restaurant_id]

    recommended_table = determine_table(@restaurant, avail_tables, new_res, r_start_time, 2.hours)

    p '===RECOMMENDED TABLE==='
    p recommended_table

    if recommended_table
      new_res[:start_time] = r_start_time
      new_res[:end_time] = r_start_time + 2.hours
      new_res[:table_id] = recommended_table.id
      if new_res.save!
        redirect_to restaurant_path(params[:restaurant_id])
      else
        flash['alert'] = 'Error. Please check input parameters'
        render :new
      end
    else
      flash['alert'] = 'There are no tables available at that time. Please try again with a different timeslot.'
      render :new
    end
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
    # ERROR HERE: INVALID FOREIGN KEY for Invoices
    if @reservation.destroy!
      redirect_to restaurant_reservations_path(@restaurant)
    else
      render :new
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:name, :party_size, :start_time)
  end

  def check_user_is_part_of_reservation
    if current_user[:id] != @reservation[:user_id] && !current_user.restaurants.include?(@reservation.restaurant)
      flash['alert'] = 'You do not have permission to access that page'
      redirect_to edit_user_registration_path
    end
  end
end
