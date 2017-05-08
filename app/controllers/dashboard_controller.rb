class DashboardController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :check_user_is_part_of_restaurant

  def index
    @restaurant_id = current_user.restaurant_id
    puts "current user restaurant id #{@restaurant_id}"
    @reservations = Reservation.where(restaurant_id: @restaurant_id).order('start_time ASC')
    @tables = Table.where(restaurant_id: @restaurant_id).order('LOWER(name) ASC')
  end
end
