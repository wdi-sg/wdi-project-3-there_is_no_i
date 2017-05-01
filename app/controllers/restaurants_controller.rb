class RestaurantsController < ApplicationController
  def index
    @restaurant = Restaurant.all
  end

  def new
    @restaurant = Restaurant.new
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    if @restaurant.save!
      @user = User.find(1) # Change when auth
      @user.restaurant_id = @restaurant.id
      @user.save!
      redirect_to restaurant_path(@restaurant)
    else
      render :new
    end
  end

  def show
    @user = User.find(1) # Change when auth
    @restaurant = Restaurant.find(params[:id])
    @menu_items = MenuItem.where(restaurant_id: params[:id])
  end

  def edit
    @restaurant = Restaurant.find(params[:id])
  end

  def update
    if Restaurant.update(params[:id], restaurant_params)
      redirect_to restaurant_path
    else
      render :edit
    end
  end

  def destroy
    Restaurant.find(params[:id]).destroy
    redirect_to user_path
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:name, :address1, :address2, :address_city, :address_state, :address_country, :address_postal, :email, :phone, :website, :description, :cuisine, :picture)
  end
end
