module AuthenticateRestaurantUser
  def check_user_is_part_of_restaurant
    if !current_user.restaurants.include? @restaurant
      flash['alert'] = "You do not have permission to access that page"
      redirect_to restaurants_path
    end
  end

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end

  # for nested routes
  def set_restaurant_id
    @restaurant = Restaurant.find(params[:restaurant_id])
  end
end
