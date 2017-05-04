module AuthenticateRestaurantUser
  def check_user_is_part_of_restaurant
    if current_user[:restaurant_id] != @restaurant[:id]
      flash['alert'] = 'You do not have permission to access that page'
      redirect_to restaurants_path
    end
  end
end
