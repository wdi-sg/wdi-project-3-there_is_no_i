class RestaurantsController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!, except: [:index, :show, :name_sort]
  before_action :set_restaurant, only: [:show, :update, :destroy]
  before_action :set_user_restaurant, only: [:edit]
  before_action :set_user, only: [:create, :destroy]
  before_action :check_user_is_part_of_restaurant, except: [:index, :new, :create, :show, :reset_queue]
  helper RestaurantsHelper

  def index
    first = params[:search]? params[:search].downcase : ''
    second = params[:city]? params[:search].downcase : ''
    x = Restaurant.where("LOWER(name) LIKE ? AND LOWER(address_city) LIKE ?", "%#{first}%", "%#{second}%")
    if request.fullpath == '/restaurants?name=sort'
      @restaurant = x.order(:name)
    elsif request.fullpath == '/restaurants?cuisine=sort'
      @restaurant = x.order(:cuisine)
    elsif request.fullpath == '/restaurants?city=sort'
      @restaurant = x.order(:address_city)
    elsif request.fullpath == '/restaurants?rating=sort'
      @restaurant = x.order('rating DESC')
    else
      @restaurant = x.order('id ASC')
    end
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    @restaurant.next_queue_number = 1
    if @restaurant.save!
      @user.restaurant_id = @restaurant.id
      @user.save!
      @user.restaurants << @restaurant
      redirect_to restaurant_path(@restaurant)
    else
      render :new
    end
  end

  def new
    @restaurant = Restaurant.new
  end

  def edit
    # @users = User.where(restaurant_id: @restaurant[:id])
  end

  def show
  end

  def update
    uploaded_file = params[:restaurant][:picture].path
    cloudinary_file = Cloudinary::Uploader.upload(uploaded_file)
    puts "START"
    puts cloudinary_file["secure_url"]
    puts "END"

    if params[:restaurant][:add]
      if User.where(email: params[:restaurant][:email]).count > 0
        User.where(email: params[:restaurant][:email])[0].restaurants << @restaurant
        flash[:notice] = 'User added'
        redirect_to dashboard_path
      else
        flash[:alert] = "There was an error adding the user. Please try again."
        @users = User.where(restaurant_id: @restaurant[:id])
        render :edit
      end
    else
      # my_params = restaurant_params
      # puts "START"
      # puts my_params
      # puts "END"
      # my_params[:restaurant][:picture] =

      if @restaurant.update(restaurant_params)
        @restaurant.update(picture: cloudinary_file["secure_url"])
        redirect_to restaurant_path
      else
        flash[:alert] = "There was an error editing. Please try again."
        @users = User.where(restaurant_id: @restaurant[:id])
        render :edit
      end
    end
  end

  def name_sort
    @restaurant = Restaurant.all.order(:name)
    render 'index'
  end

  def destroy
    @user.restaurant_id = nil
    @restaurant.destroy
    redirect_to restaurants_path
  end

  def reset_queue
    the_restaurant = Restaurant.find(params[:restaurant_id])
    # Cannot change when there are existing users in the queue
    if Reservation.where(restaurant_id: the_restaurant.id).where(status: 'queuing').count > 0
      flash[:alert] = "Unable to reset queue number. Please ensure that there are no customers in the queue"
      redirect_to restaurant_path(the_restaurant)
    else
      the_restaurant.next_queue_number = 1
      if the_restaurant.save!
        p 'TROUBLESHOOT'
        p the_restaurant
        redirect_to restaurant_path(the_restaurant)
      else
        flash[:alert] = "Error 500. Unable to update restaurant queue number"
        redirect_to restaurant_path(the_restaurant)
      end
    end
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
