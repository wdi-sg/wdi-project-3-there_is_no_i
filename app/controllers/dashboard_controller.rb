class DashboardController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!
  before_action :check_if_user_has_set_primary_restaurant
  before_action :set_user_restaurant
  before_action :check_user_is_part_of_restaurant

  def index
    add_breadcrumb 'Orders', restaurant_orders_path(@restaurant)
    add_breadcrumb 'Invoices', restaurant_invoices_path(@restaurant)
    add_breadcrumb 'Menu', restaurant_menu_items_path(@restaurant)
    add_breadcrumb 'Tables', restaurant_tables_path(@restaurant)
    add_breadcrumb 'Public Queue', restaurant_new_public_path(@restaurant)
    @restaurant_id = current_user.restaurant_id
    @reservations = Reservation.where(restaurant_id: @restaurant_id).order('start_time ASC')
    @tables = Table.where(restaurant_id: @restaurant_id).order('LOWER(name) ASC')
    gon.restaurant_id = @restaurant.id
  end
end
