class WalkinsController < ApplicationController
  before_action :set_restaurant, only: %i[index new create public_new public_create edit update destroy]
  before_action :set_walkin, only: %i[show edit update destroy]
  helper ReservationsHelper

  # Probably need another model for diners?
  # OR
  # change is_queuing to status: "is_dining / is_queuing / on_reservation"

  def index
    @walkins = Reservation.where(restaurant_id: params[:restaurant_id], is_queuing: true)
  end

  # Customer has no phone?
  def create
    @walkin = Reservation.new(walkin_params)
    @walkin.restaurant_id = @restaurant.id
    @walkin.is_queuing = true
    if @walkin.save!
      redirect_to restaurant_walkins_path(@restaurant)
    else
      render :new
    end
  end

  def new
    @walkin = Reservation.new
  end

  def public_create
    @walkin = Reservation.new(walkin_params)
    @walkin.restaurant_id = @restaurant.id
    @walkin.is_queuing = true
    set_walkin_user(@walkin)
    if @walkin.save!
      redirect_to restaurant_public_path(@restaurant)
    else
      render :new
    end
  end

  def public_new
    @walkin = Reservation.new
    render 'layouts/public_walkin_new', :layout => false
  end

  def edit; end

  def show; end

  def update
    if @walkin.update(walkin_params)
      redirect_to restaurant_walkins_path(@restaurant)
    else
      render :edit
    end
  end

  def destroy
    @walkin.destroy
    redirect_to restaurant_walkins_path(@restaurant)
  end

  private

  def set_walkin_user(walkin)
    user = User.where(phone: walkin.phone)
    if user.count == 1
      walkin.user_id = user.pluck(:id)[0]
      walkin.name = user.pluck(:name)[0]
      walkin.email = user.pluck(:email)[0]
    # NEED TO CHECK IF CUSTOMER SUBMIT MULTIPLE TIMES --> Change!
    # elsif (user.count > 1 && walkin.phone)
    #   walkin.name = 'Walk in Customer (WARNING! Duplicate User number)'
    else
      walkin.name = 'Walk in Customer (Mobile Signin)'
    end
  end

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_walkin
    @walkin = Reservation.find(params[:id])
  end

  def walkin_params
    params.require(:reservation).permit(:name, :phone, :email, :party_size, :special_requests, :is_queuing)
  end
end
