class ReservationsController < ApplicationController
  def new
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def index
    @reservations = Reservation.where(restaurant_id: params[:restaurant_id])
  end

  def create
    d = Time.parse(params[:reservation][:date])
    day = d.strftime('%d')
    month = d.strftime('%m')
    year = d.strftime('%Y')
    t = Time.parse(params[:reservation][:time])
    date_time = t.change(day: day, month: month, year: year, offset: +0o000)
    puts date_time
    new_res = {}
    new_res[:name] = params[:reservation][:name]
    new_res[:phone] = params[:reservation][:phone]
    new_res[:date_time] = date_time
    new_res[:party_size] = params[:reservation][:party_size]
    new_res[:restaurant_id] = params[:restaurant_id]

    @reservation = Reservation.new(new_res)

    if @reservation.save
      redirect_to restaurant_path(params[:restaurant_id])
    else
      render :new
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit(:name, :party_size, :date_time)
  end
end
