module AuthenticateRestaurantUser
  def check_user_is_part_of_restaurant
    if !current_user.restaurants.include?(@restaurant)
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
