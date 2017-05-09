class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :name_sort]
  before_action :set_user
  helper UsersHelper

  def invoices
    @user = current_user
  end

  def reservations
    @user = current_user
  end

  private

  def set_user
    @user = current_user
  end
end
