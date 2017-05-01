class RestaurantsController < ApplicationController
  def index
    @restaurant = Restaurant.all
  end

  def new
    @restaurant = Restaurant.new
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    if @restaurant.save
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @restaurant = Restaurant.find(params[:id])
  end


  # def call
  # end


  # def reserve
  # end

  # def menu
  # end

  private

  # def restaurant_params
  #   params.require(:restaurant).permit(:name, :email, :password, :password_confirmation)
  # end
end
