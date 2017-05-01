class RestaurantsController < ApplicationController
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
  end


  # def call
  # end

  def reserve
    @reserve = Reservation.new()
  end


  # def reserve
  # end

  # def menu
  # end

  private

  # def restaurant_params
  #   params.require(:restaurant).permit(:name, :email, :password, :password_confirmation)
  # end

  # def reserve_params
  #   params.require(:reserve).permit()
  #   # params.require(:tweet).permit(:content, :username)

  # def reserve_params
  #   permitted = params.require(:reserve).permit(:party_size, :date, :time)

  # end
end
