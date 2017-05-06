class OrdersController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!
  before_action :set_restaurant_id
  before_action :set_invoice, only: [:create, :new]
  before_action :set_invoice_and_order, only: [:update, :destroy]
  before_action :check_user_is_part_of_restaurant

    def index
      @orders = @restaurant.orders
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

    def update
    if @order.update!(time_end: DateTime.now)
      redirect_to restaurant_orders_path(@restaurant)
    else
      render html: @order.inspect
    end
    end

    def destroy
      @order.destroy
      redirect_to restaurant_invoice_path(@restaurant, @invoice)
    end

    private

    def set_invoice
      @invoice = Invoice.find(params[:invoice_id])
    end

    def set_invoice_and_order
      @order = Order.find(params[:id])
      @invoice = @order.invoice
    end

    # def order_params
    #   params.require(:order).permit(:user_id, :restaurant_id, :menu_item_id, :request_description, :is_takeaway, :time_end)
    # end

  end
