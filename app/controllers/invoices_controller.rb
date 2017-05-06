class InvoicesController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!
  before_action :set_restaurant_id
  before_action :set_invoice, only: [:edit, :show, :update, :destroy]
  before_action :check_user_is_part_of_restaurant, only: [:index]
  before_action :check_user_is_part_of_invoice, only: [:edit, :show, :update, :destroy]

    def index
      @invoices = Invoice.where(restaurant_id: params[:restaurant_id]).order('created_at ASC')
    end

    def create
      @invoice = Invoice.new(invoice_params)
      if @invoice.save!
        redirect_to restaurant_invoices_path(@restaurant)
      else
        render :new
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

    def invoice_params
      params.require(:invoice).permit(:user_id, :name, :table_id, :restaurant_id, :time_end, :takeaway_time, :reservation_id)
    end

    # SYNTAX ERROR ON HEROKU when :check_user_is_part_of_invoice was used
    def check_user_is_part_of_invoice
      if current_user[:id] != @invoice[:user_id]
        flash['alert'] = 'You do not have permission to access that page'
        redirect_to edit_user_registration_path
      end
    end
  end
