class RestaurantsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_restaurant, only: [:edit, :show, :update, :destroy]
  before_action :set_user, only: [:create, :destroy]
  before_action :authenticate_restaurant_user!, except: [:index, :show]
  helper RestaurantsHelper

  def index
    @restaurant = Restaurant.all
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    if @restaurant.save!
      @user.restaurant_id = @restaurant.id
      @user.save!
      redirect_to restaurant_path(@restaurant)
    else
      render :new
    end
  end

  def new
    @restaurant = Restaurant.new
  end

  def edit
  end

  def show
  end

  def update
    if @restaurant.update(restaurant_params)
      redirect_to restaurant_path
    else
      render :edit
    end
  end

  def destroy
    @user.restaurant_id = nil
    @restaurant.destroy
    redirect_to restaurants_path
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end

  def set_user
    @user = User.find(1) # Change when auth
  end

  def restaurant_params
    params.require(:restaurant).permit(:name, :address1, :address2, :address_city, :address_state, :address_country, :address_postal, :email, :phone, :website, :description, :cuisine, :picture)
  end

  def authenticate_restaurant_user
    flash['alert'] = 'You do not have permission to access that page'
    redirect_to restaurants_path if current_user[:restaurant_id] != @restaurant[:id]
  end
end
