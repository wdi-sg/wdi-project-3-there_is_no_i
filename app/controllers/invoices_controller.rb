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
# @index = 0
    def create
      # @index += 1
      # params[:orders]
      if current_user
      @invoice = Invoice.new(restaurant_id: @restaurant.id, user_id: current_user.id)
    #   # @index
    else
      @invoice = Invoice.new(restaurant_id: @restaurant.id)
    #   @index
    end
    #   # @invoice.restaurant_id = @restaurant.id
      if @invoice.save!
    x = params[:orders].split('/')
      if current_user
    x.each do |x|
      Order.create(user_id: current_user.id, is_take_away: true, invoice_id: @invoice.id, menu_item_id: x)
    end
else
  x.each do |x|
    Order.create(is_take_away: true, invoice_id: @invoice.id, menu_item_id: x)
  end
end
  #code
else
        # redirect_to restaurant_menu_items_path(@restaurant)
    #   else
        render html: @invoice
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