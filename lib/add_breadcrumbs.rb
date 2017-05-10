module AddBreadcrumbs
  def add_index_breadcrumbs
      add_breadcrumb "Restaurants", :restaurants_path
      add_breadcrumb @restaurant.name, restaurant_path(@restaurant)
  end

  def add_full_breadcrumbs(description, path)
      add_breadcrumb "Restaurants", :restaurants_path
      add_breadcrumb @restaurant.name, restaurant_path(@restaurant)
      add_breadcrumb description, path
  end
end
