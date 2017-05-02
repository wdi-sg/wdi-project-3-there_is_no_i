class TablesController < ApplicationController
  before_action :set_restaurant, only: [:index, :create, :edit, :update, :destroy]
  before_action :set_table, only: [:show, :edit, :update, :destroy]

  def index
    @tables = Table.where(restaurant_id: params[:restaurant_id]).order('name ASC')
  end

  def create
    @table = Table.new(table_params)
    @table.capacity_current = 0
    @table.restaurant_id = @restaurant.id
    if @table.save!
      redirect_to restaurant_tables_path(@restaurant)
    else
      render :new
    end
  end

  def new
    @table = Table.new
  end

  def edit
  end

  def show
  end

  def update
    if @table.update(table_params)
      redirect_to restaurant_tables_path(@restaurant)
    else
      render :edit
    end
  end

  def destroy
    @table.destroy
    redirect_to restaurant_tables_path(@restaurant)
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_table
    @table = Table.find(params[:id])
  end

  def table_params
    params.require(:table).permit(:name, :capacity_total)
  end
end
