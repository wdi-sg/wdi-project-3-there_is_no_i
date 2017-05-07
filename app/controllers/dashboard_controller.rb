class DashboardController < ApplicationController
  def index
    @restaurant_id = params[:restaurant_id]
    @reservations = Reservation.where(restaurant_id: params[:restaurant_id]).order('start_time ASC')
  end
end
