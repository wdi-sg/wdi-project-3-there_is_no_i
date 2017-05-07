class InvoicesController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!
  before_action :set_restaurant_id
  before_action :set_invoice, only: [:edit, :show, :update, :destroy]
  before_action :check_user_is_part_of_restaurant, except: [:create, :new, :show]
  before_action :check_user_is_part_of_invoice, only: [:show]
  helper InvoicesHelper

    def index
      @invoices = Invoice.where(restaurant_id: params[:restaurant_id]).order('created_at ASC')
    end

    def create
      if current_user
        @invoice = Invoice.new(restaurant_id: @restaurant.id, user_id: current_user.id)
      else
        @invoice = Invoice.new(restaurant_id: @restaurant.id)
      end

      if @invoice.save!
        orders = params[:orders].split('/')

        if current_user
          orders.each do |menu_item|
            @order = Order.create(user_id: current_user.id, is_take_away: params[:is_take_away], invoice_id: @invoice.id, menu_item_id: menu_item)
            ActionCable.server.broadcast('room_channel', {invoice: @invoice.id, received: @order.created_at, item: @order.menu_item.name, is_take_away: params[:is_take_away], restaurant: @restaurant.id})
          end
        else
          orders.each do |menu_item|
            @order = Order.create(is_take_away: params[:is_take_away], invoice_id: @invoice.id, menu_item_id: menu_item)
            ActionCable.server.broadcast('room_channel', {invoice: @invoice.id, received: @order.created_at, item: @order.menu_item.name, is_take_away: params[:is_take_away], restaurant: @restaurant.id})
          end
        end
        flash[:notice] = "Thanks for ordering takeaway. You should receive an email confirmation soon."
        redirect_to restaurant_path(@restaurant)
      else
        flash[:alert] = "There was an error submitting your order. Please try again."
        redirect_to restaurant_menu_items_path(@restaurant)
      end
    end

    def new
      @invoice = Invoice.new
    end

    def edit
    end

    def show
    end

    def update
      if @invoice.update(invoice_params)
        redirect_to restaurant_invoices_path(@restaurant)
      else
        render :edit
      end
    end

    def destroy
      @invoice.destroy
      redirect_to restaurant_invoices_path(@restaurant)
    end

    private

    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    # def invoice_params
    #   params.require(:invoice).permit(:user_id, :user_name, :table_id, :restaurant_id, :time_end, :takeaway_time, :reservation_id)
    # end

    def check_user_is_part_of_invoice
      if current_user[:id] != @invoice[:user_id] && !current_user.restaurants.include?(@invoice.restaurant)
        flash['alert'] = 'You do not have permission to access that page'
        redirect_to edit_user_registration_path
      end
    end
  end
