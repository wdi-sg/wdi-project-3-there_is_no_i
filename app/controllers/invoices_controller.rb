class InvoicesController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!, except: [:create]
  before_action :set_restaurant_id
  before_action :set_invoice, only: [:edit, :show, :update, :destroy]
  before_action :check_user_is_part_of_restaurant, except: [:create, :show]
  before_action :check_user_is_part_of_invoice, only: [:show]
  helper InvoicesHelper

    def index
      @invoices = Invoice.where(restaurant_id: params[:restaurant_id]).order('created_at ASC')
    end

    def create
      if !params[:is_take_away]
        # convert amount in dollars to amount in cents
        @amount = params[:total_price].to_f
        @amount = (@amount * 100).to_i

        begin
        customer = Stripe::Customer.create(
        :email => params[:stripeEmail],
        :source => params[:stripeToken]
        )

        charge = Stripe::Charge.create(
        :customer => customer.id,
        :amount => @amount,
        :description => 'Takeaway',
        :currency => 'SGD'
        )

        rescue Stripe::CardError => e
          flash[:alert] = e.message
          redirect_to restaurant_menu_items_path(@restaurant)
        end

        @x = User.where(email: params[:stripeEmail])
      else
        @x = []
      end

      takeaway_time = Time.zone.local( params[:order]["time(1i)"].to_i, params[:order]["time(2i)"].to_i, params[:order]["time(3i)"].to_i, params[:order]["time(4i)"].to_i, params[:order]["time(5i)"].to_i, 0)

      if params[:invoice_id]
        @invoice = Invoice.find(params[:invoice_id])
      elsif params[:order][:time]
        @invoice = Invoice.new(restaurant_id: @restaurant.id, user_id: current_user.id, takeaway_time: takeaway_time)
      # elsif Reservations.where(user_id: current_user.id).where(status: 'reservation').count > 0
      #   @invoice = Invoice.new(restaurant_id: @restaurant.id, user_id: current_user.id, takeaway_time: takeaway_time)
      elsif @x.count > 0
        @invoice = Invoice.new(restaurant_id: @restaurant.id, user_id: @x[0].id)
      else
        @invoice = Invoice.new(restaurant_id: @restaurant.id, user_id: current_user.id)
      end

      if @invoice.save!
        orders = params[:orders].split('/')

        if current_user
          orders.each do |menu_item|
            @order = Order.create(user_id: current_user.id, is_take_away: params[:is_take_away], invoice_id: @invoice.id, menu_item_id: menu_item, request_description: params[:request])
            ActionCable.server.broadcast('room_channel', {invoice: @invoice.id, received: @order.created_at, item: @order.menu_item.name, is_take_away: params[:is_take_away], restaurant: @restaurant.id, request_description: params[:request]})
          end
        else
          orders.each do |menu_item|
            @order = Order.create(is_take_away: params[:is_take_away], invoice_id: @invoice.id, menu_item_id: menu_item, request_description: params[:request])
            ActionCable.server.broadcast('room_channel', {invoice: @invoice.id, received: @order.created_at, item: @order.menu_item.name, is_take_away: params[:is_take_away], restaurant: @restaurant.id, request_description: params[:request]})
          end
        end

        if params[:is_take_away] == "true"
          flash[:notice] = "Thanks for ordering takeaway. You should receive an email confirmation soon."
          redirect_to restaurant_path(@restaurant)
        else
          flash[:notice] = "Local order created."
          redirect_to dashboard_path
        end
      else
        flash[:alert] = "There was an error submitting your order. Please try again."
        redirect_to restaurant_menu_items_path(@restaurant)
      end
    end

    def edit
      @table_options = @restaurant.tables.map do |table|
        [table.name, table.id]
      end
    end

    def show
    end

    def update
      if params[:time_end] == ''
        if @invoice.update(time_end: DateTime.now)
          flash[:notice] = 'Invoice successfully updated'
        else
          flash[:alert] = 'There was a problem updating the invoice. Please try again.'
        end
        redirect_to restaurant_invoices_path(@restaurant)
      else
        if @invoice.update(invoice_params)
          flash[:notice] = 'Invoice successfully updated'
          redirect_to restaurant_invoices_path(@restaurant)
        else
          flash[:alert] = 'There was a problem updating the invoice. Please try again.'
          render :edit
        end
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

    def invoice_params
      params.require(:invoice).permit(:user_name, :table_id, :time_end, :takeaway_time)
    end

    def check_user_is_part_of_invoice
      if current_user[:id] != @invoice[:user_id] && !current_user.restaurants.include?(@invoice.restaurant)
        flash['alert'] = 'You do not have permission to access that page'
        redirect_to edit_user_registration_path
      end
    end
  end
