class MenuItemsController < ApplicationController
  def index
    @menu_items = MenuItem.where(restaurant_id: params[:restaurant_id])
  end

  def create
    
  end

  def new

  end

  def edit

  end

  def show

  end

  def update

  end

  def destroy

  end
end
