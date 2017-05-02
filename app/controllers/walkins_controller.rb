class WalkinsController < ApplicationController
  before_action :set_restaurant, only: %i[index create edit update destroy]
  before_action :set_reservation, only: %i[show edit update destroy]

  def index
    @reservations = Reservation.where(restaurant_id: params[:restaurant_id], is_queuing: true)
  end

  def create
    d = Time.parse(params[:reservation][:date])
    day = d.strftime('%d')
    month = d.strftime('%m')
    year = d.strftime('%Y')
    t = Time.parse(params[:reservation][:time])
    date_time = t.change(day: day, month: month, year: year, offset: +0o000)
    puts date_time
    x = {}
    x[:name] = params[:reservation][:name]
    x[:phone] = params[:reservation][:phone]
    x[:date_time] = date_time
    x[:party_size] = params[:reservation][:party_size]
    x[:restaurant_id] = params[:restaurant_id]
    puts x
  end

  def new
    @reservation = Reservation.new
  end

  def edit; end

  def show; end

  def update; end

  def destroy; end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def walkin_params
    params.require(:walkin).permit(:party_size, :phone)
  end
end
