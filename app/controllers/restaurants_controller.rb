class RestaurantsController < ApplicationController
  def index
  end

  def show
  end

  def call
  end

  def reserve
  end

  def menu
  end

  private

  def reserve_params
    params.require(:reserve).permit()
    # params.require(:tweet).permit(:content, :username)
  end
end
