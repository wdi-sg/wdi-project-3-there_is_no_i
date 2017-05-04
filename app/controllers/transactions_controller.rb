class TransactionsController < ApplicationController
    before_action :set_restaurant, only: [:index, :create, :edit, :update, :destroy]
    before_action :set_transaction, only: [:edit, :show, :update, :destroy]

    def index
      @transactions = Transaction.where(restaurant_id: params[:restaurant_id]).order('name ASC')
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

    def set_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    def transaction_params
      params.require(:transaction).permit(:name, :capacity_total)
    end
  end
