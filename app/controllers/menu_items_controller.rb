class MenuItemsController < ApplicationController
  def index
    @menu_items = MenuItem.where(restaurant_id: params[:restaurant_id])
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def new
    @menu_item = MenuItem.new
  end

  def create
    @menu_item = MenuItem.new(menu_item_params)
    @restaurant = Restaurant.find(params[:restaurant_id])
    @menu_item.restaurant_id = @restaurant.id
    if @menu_item.save!
      redirect_to restaurant_menu_items_path(@restaurant)
    else
      render :new
    end
  end

  def edit
    
  end

  def show
    @menu_item = MenuItem.find(params[:id])
  end

  def update

  end

  def destroy
    # @menu_item.destroy
    # redirect_to restaurant_menu_items(@restaurant)
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :price, :description, :ingredients, :tags)
  end
end
