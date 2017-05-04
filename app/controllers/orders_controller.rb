class OrdersController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!
  before_action :set_restaurant_id
  before_action :set_order, only: [:edit, :show, :update, :destroy]
  before_action :check_user_is_part_of_restaurant, only: [:index]
  before_action :check_user_is_part_of_order, only: [:edit, :show, :update, :destroy]

    def index
      @orders = Order.where(restaurant_id: params[:restaurant_id]).order('created_at ASC')
    end

    def create
      @order = Order.new(order_params)
      if @order.save!
        redirect_to restaurant_orders_path(@restaurant)
      else
        render :new
      end
    end

    def new
      @order = Order.new
    end

    def edit
    end

    def show
    end

    def update
      if @order.update(order_params)
        redirect_to restaurant_orders_path(@restaurant)
      else
        render :edit
      end
    end

    def destroy
      @order.destroy
      redirect_to restaurant_orders_path(@restaurant)
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:user_id, :restaurant_id, :menu_item_id, :request_description, :is_takeaway, :time_end)
    end

    def :check_user_is_part_of_order
      if current_user[:id] != @order[:user_id]
        flash['alert'] = 'You do not have permission to access that page'
        redirect_to edit_user_registration_path
      end
    end
  end
