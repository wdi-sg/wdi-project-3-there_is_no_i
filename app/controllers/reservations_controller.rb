class ReservationsController < ApplicationController
  def new
    @reservation = Reservation.new
  end

def create
  @reservation = Reservation.create(reservation_params)
end
end

private

def reservation_params
  params.require(:reservation).permit(:party_size, :date, :time)
end
