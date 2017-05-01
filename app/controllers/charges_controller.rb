class ChargesController < ApplicationController
  before_action :get_order_data_from_params, only: [:create]

  def new
    @hello = [['chicken rice', 500],['char kway teow', 620],['bak chor mee', 700]]
  end

  def create
    # @amount in cents

    customer = Stripe::Customer.create(
    :email => params[:stripeEmail],
    :source => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
    :customer => customer.id,
    :amount => @amount,
    :description => @description,
    :currency => 'SGD'
    )

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end
end

private

def get_order_data_from_params
  @amount = params[:amount]
  @description = params[:description]
end
