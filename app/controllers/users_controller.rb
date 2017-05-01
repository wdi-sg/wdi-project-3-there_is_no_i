class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save!
      redirect_to users_path
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
    if @user.restaurant_id
      @restaurant = Restaurant.find(@user.restaurant_id)
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    if User.update(params[:id], user_params)
      redirect_to user_path
    else
      render :edit
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :phone, :password)
  end
end
