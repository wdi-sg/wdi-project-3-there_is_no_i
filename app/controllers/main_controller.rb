class MainController < ApplicationController
  include SendEmail
  def index
    @is_main = true

  end
end
