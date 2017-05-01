class ReservationsController < ApplicationController
  def new
    # @reservation = Reservation.new
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

def create
  puts params[:party_size]
@reservation = Reservation.new(reservation_params)
    if @reservation.save
    redirect_to restaurant_path
  else
    render :new
  end
end

private

def reservation_params
  params.require(:reservation).permit(:party_size, :date, :time)
end
end
