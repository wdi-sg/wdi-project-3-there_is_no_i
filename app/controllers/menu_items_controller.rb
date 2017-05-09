class MenuItemsController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!, except: [:index, :show, :redirect]
  before_action :set_restaurant_id, except: [:redirect]
  before_action :set_menu_item, only: [:edit, :show, :update, :destroy]
  before_action :check_user_is_part_of_restaurant, except: [:index, :show, :redirect]
  before_action :check_if_invoice_or_reservation_exists, only: [:index]
  helper MenuItemsHelper

  def index
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb "Back to restaurant", restaurant_path(@restaurant)
    gon.restaurant = @restaurant.name
    gon.description = @existing_invoice == '' && @reservation == '' ? 'Takeaway' : 'Order'
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
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb "Back to restaurant", restaurant_path(@restaurant)
    add_breadcrumb "Back to menu", restaurant_menu_items_path(@restaurant)
    @menu_item = MenuItem.new
  end

  def edit
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb "Back to restaurant", restaurant_path(@restaurant)
  end

  def show
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb "Back to restaurant", restaurant_path(@restaurant)
  end

  def update
    if params[:menu_item][:picture] && params[:menu_item][:picture].path
      uploaded_file = params[:restaurant][:picture].path
      @cloudinary_file = Cloudinary::Uploader.upload(uploaded_file)
    end

    if @menu_item.update(menu_item_params)
      if params[:menu_item][:picture] && params[:menu_item][:picture].path
        @menu_item.update(picture: @cloudinary_file["secure_url"])
      end
      redirect_to restaurant_menu_items_path(@restaurant)
    else
      render :edit
    end
  end

  def destroy
    @menu_item.update(restaurant_id: nil)
    redirect_to restaurant_menu_items_path(@restaurant)
  end

  private

  def set_menu_item
    @menu_item = MenuItem.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :price, :description, :ingredients, :tags)
  end

  def check_if_invoice_or_reservation_exists
    @existing_invoice = params[:invoice_id] ? params[:invoice_id] : ''
    @reservation = params[:reservation_id] ? params[:reservation_id] : ''
    if params[:invoice_id]
      @table = Invoice.find(params[:invoice_id]).table ? Invoice.find(params[:invoice_id]).table.name : '-'
      @is_take_away = false
    elsif params[:reservation_id]
      @is_take_away = false
      @table = ''
    elsif current_user.restaurants.include? @restaurant
      @is_take_away = false
      @table = ''
    else
      @is_take_away = true
      @table = ''
    end
  end
end
