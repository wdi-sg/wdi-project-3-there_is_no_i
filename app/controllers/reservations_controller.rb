class ReservationsController < ApplicationController
  def new
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def index
    @reservations = Reservation.all
  end

  def create
    d = Time.parse(params[:reservation][:date])
    day = d.strftime('%d')
    month = d.strftime('%m')
    year = d.strftime('%Y')
    t = Time.parse(params[:reservation][:time])
    date_time = t.change(day: day, month: month, year: year)
    puts date_time
    x = {}
    x[:name] = params[:reservation][:name]
    x[:phone] = params[:reservation][:phone]
    x[:date_time] = date_time
    x[:party_size] = params[:reservation][:party_size]
    x[:restaurant_id] = params[:restaurant_id]
    puts x

    @reservation = Reservation.new(x)

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
