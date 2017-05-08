class MenuItemsController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_restaurant_id
  before_action :set_menu_item, only: [:edit, :show, :update, :destroy]
  before_action :check_user_is_part_of_restaurant, except: [:index, :show]
  helper MenuItemsHelper

  def index
    if current_user
      if current_user.restaurants.include? @restaurant
        @is_take_away = false
      else
        @is_take_away = true
      end
    else
      @is_take_away = true
    end
      @restaurant_id = params[:restaurant_id]
    if request.fullpath == "/restaurants/#{@restaurant_id}/menu_items?name=sort"
      @menu_items = MenuItem.where(restaurant_id: params[:restaurant_id]).order(:name)
    elsif request.fullpath == "/restaurants/#{@restaurant_id}/menu_items?price=sort"
      @menu_items = MenuItem.where(restaurant_id: params[:restaurant_id]).order(:price)
    elsif request.fullpath == "/restaurants/#{@restaurant_id}/menu_items?description=sort"
      @menu_items = MenuItem.where(restaurant_id: params[:restaurant_id]).order(:description)
    elsif request.fullpath == "/restaurants/#{@restaurant_id}/menu_items?ingredient=sort"
      @menu_items = MenuItem.where(restaurant_id: params[:restaurant_id]).order(:ingredients)
    elsif request.fullpath == "/restaurants/#{@restaurant_id}/menu_items?tag=sort"
      @menu_items = MenuItem.where(restaurant_id: params[:restaurant_id]).order(:tags)
    else
      @menu_items = MenuItem.where(restaurant_id: params[:restaurant_id]).order('LOWER(name) ASC')
    end
  end

  def create
    @menu_item = MenuItem.new(menu_item_params)
    @menu_item.restaurant_id = @restaurant.id
    if @menu_item.save!
      redirect_to restaurant_menu_items_path(@restaurant)
    else
      render :new
    end
  end

  def new
    @menu_item = MenuItem.new
  end

  def edit
  end

  def show
  end

  def update
    if @menu_item.update(menu_item_params)
      redirect_to restaurant_menu_items_path(@restaurant)
    else
      render :edit
    end
  end

  def destroy
    @menu_item.destroy
    redirect_to restaurant_menu_items_path(@restaurant)
  end

  private

  def set_menu_item
    @menu_item = MenuItem.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :price, :description, :ingredients, :tags)
  end
end
