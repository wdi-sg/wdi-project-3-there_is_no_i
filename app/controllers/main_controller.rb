class MainController < ApplicationController
  def index
    @is_main = true
  end

  def get_signup
    @user = User.new
  end

  def post_signup
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Account Created. Please Login"
      redirect_to root_path
    else
      render :new
    end
  end

  def get_login
  end

  def logout
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
