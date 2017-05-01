class RestaurantsController < ApplicationController
  def index
  end

  def show
  end

  def call
  end

  def reserve
    @reserve = Reservation.new()
  end

  def menu
  end

  private

  # def reserve_params
  #   permitted = params.require(:reserve).permit(:party_size, :date, :time)
  # end
end
