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
      @user = User.find(1)
      @user.restaurant_id = @restaurant.id
      @user.save!
      redirect_to restaurant_path(@restaurant)
    else
      render :new
    end
  end

  def show
    @restaurant = Restaurant.find(params[:id])
  end

  def edit
    
  end

  def update

  end

  def destroy

  end

  private
  
  def restaurant_params
    params.require(:restaurant).permit(:name, :address1, :address2, :city, :state, :country, :postal, :description, :cuisine, :email)
  end
end
