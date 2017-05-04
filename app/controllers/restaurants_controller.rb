class RestaurantsController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_restaurant, only: [:show, :update, :destroy]
  before_action :set_user_restaurant, only: [:edit]
  before_action :set_user, only: [:create, :destroy]
  before_action :check_user_is_part_of_restaurant, except: [:index, :new, :create, :show]
  helper RestaurantsHelper

  def index
    @restaurant = Restaurant.all.order('id ASC')
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
    @users = User.where(restaurant_id: @restaurant[:id])
  end

  def show
  end

  def update
    if params[:restaurant][:add]
      if User.where(email: params[:restaurant][:email]).count > 0
        User.where(email: params[:restaurant][:email]).update(restaurant_id: @restaurant[:id])
        flash[:notice] = 'User added'
        redirect_to dashboard_path
      else
        flash[:alert] = "There was an error adding the user. Please try again."
        @users = User.where(restaurant_id: @restaurant[:id])
        render :edit
      end
    else
      if @restaurant.update(restaurant_params)
        redirect_to restaurant_path
      else
        flash[:alert] = "There was an error editing. Please try again."
        @users = User.where(restaurant_id: @restaurant[:id])
        render :edit
      end
    end
  end

  def destroy
    @user.restaurant_id = nil
    @restaurant.destroy
    redirect_to restaurants_path
  end

  private

  def set_user
    @user = current_user
  end

  def set_user_restaurant
    if current_user[:restaurant_id]
      @restaurant = Restaurant.find(current_user[:restaurant_id])
    else
      flash['alert'] = 'You need to register a restaurant to access that page'
      redirect_to restaurants_path
    end
  end

  def restaurant_params
    params.require(:restaurant).permit(:name, :address1, :address2, :address_city, :address_state, :address_country, :address_postal, :email, :phone, :website, :description, :cuisine, :picture)
  end


end
