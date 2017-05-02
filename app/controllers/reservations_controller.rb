class ReservationsController < ApplicationController
  before_action :set_restaurant, only: %i[new index show create edit update destroy]
  before_action :set_reservation, only: %i[show edit update destroy]
  helper ReservationsHelper

  def new; end

  def index
    @reservations = Reservation.where(restaurant_id: params[:restaurant_id]).order('start_time ASC')
  end

  def create
    d = Time.parse(params[:reservation][:date])
    day = d.strftime('%d')
    month = d.strftime('%m')
    year = d.strftime('%Y')
    t = Time.parse(params[:reservation][:time])
    start_time = t.change(day: day, month: month, year: year, offset: +0o000)
    puts start_time
    new_res = {}
    new_res[:name] = params[:reservation][:name]
    new_res[:phone] = params[:reservation][:phone]
    new_res[:start_time] = start_time
    new_res[:party_size] = params[:reservation][:party_size]
    new_res[:restaurant_id] = params[:restaurant_id]

    @reservation = Reservation.new(new_res)

    if @reservation.save
      redirect_to restaurant_path(params[:restaurant_id])
    else
      render :new
    end
  end

  def edit
    # @reservation = Reservation.find(params[:id])
  end

  def show; end

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

  def reservation_params
    params.require(:reservation).permit(:name, :party_size, :start_time)
  end

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end
end
