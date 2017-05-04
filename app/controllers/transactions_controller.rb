class TransactionsController < ApplicationController
  include AuthenticateRestaurantUser
  before_action :authenticate_user!
  before_action :set_restaurant_id
  before_action :set_transaction, only: [:edit, :show, :update, :destroy]
  before_action :check_user_is_part_of_restaurant, only: [:index]
  before_action :check_user_is_part_of_transaction, only: [:edit, :show, :update, :destroy]

    def index
      @transactions = Transaction.where(restaurant_id: params[:restaurant_id]).order('created_at ASC')
    end

    def create
      @transaction = Transaction.new(transaction_params)
      if @transaction.save!
        redirect_to restaurant_transactions_path(@restaurant)
      else
        render :new
      end
    end

    def new
      @transaction = Transaction.new
    end

    def edit
    end

    def show
    end

    def update
      if @transaction.update(transaction_params)
        redirect_to restaurant_transactions_path(@restaurant)
      else
        render :edit
      end
    end

    def destroy
      @transaction.destroy
      redirect_to restaurant_transactions_path(@restaurant)
    end

    private

    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    def transaction_params
      params.require(:transaction).permit(:user_id, :name, :table_id, :restaurant_id, :time_end, :takeaway_time, :reservation_id)
    end

    # SYNTAX ERROR ON HEROKU when :check_user_is_part_of_transaction was used
    def check_user_is_part_of_transaction
      if current_user[:id] != @transaction[:user_id]
        flash['alert'] = 'You do not have permission to access that page'
        redirect_to edit_user_registration_path
      end
    end
  end
