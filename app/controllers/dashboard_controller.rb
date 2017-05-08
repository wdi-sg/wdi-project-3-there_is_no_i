class DashboardController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!
  before_action :check_if_user_has_set_primary_restaurant
  before_action :set_user_restaurant
  before_action :check_user_is_part_of_restaurant


  def index
    @restaurant_id = current_user.restaurant_id
    puts "current user restaurant id #{@restaurant_id}"
    @reservations = Reservation.where(restaurant_id: @restaurant_id).order('start_time ASC')
    @tables = Table.where(restaurant_id: @restaurant_id).order('LOWER(name) ASC')
  end

  private

  def set_user_restaurant
    if current_user[:restaurant_id]
      @restaurant = Restaurant.find(current_user[:restaurant_id])
    else
      flash['alert'] = 'You need to register a restaurant to access that page'
      redirect_to restaurants_path
    end
  end

  def check_if_user_has_set_primary_restaurant
    if current_user.restaurants.count > 0
      if !current_user.restaurant_id
        flash[:alert] = 'You must set a primary restaurant in your account to access the dashboard'
        redirect_to edit_user_registration_path
      end
    end
  end
end
