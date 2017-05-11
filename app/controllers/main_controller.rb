class MainController < ApplicationController
  def index
    @search = params[:search]? params[:search].downcase : ''
    @city = params[:city]? params[:city].downcase : ''
    x = Restaurant.where("LOWER(name) LIKE ? OR LOWER(cuisine) LIKE ?", "%#{@search}%", "%#{@search}%").where("LOWER(address_city) LIKE ?", "%#{@city}%").paginate(page: params[:page], per_page: 9)
    if request.fullpath == "/restaurants?sort=name&search=#{@search}&city=#{@city}"
      @restaurants = x.order(:name)
    elsif request.fullpath == "/restaurants?sort=cuisine&search=#{@search}&city=#{@city}"
      @restaurants = x.order(:cuisine)
    elsif request.fullpath == "/restaurants?sort=city&search=#{@search}&city=#{@city}"
      @restaurants = x.order(:address_city)
    else
      @restaurants = x.order('id ASC')
    end
    render 'restaurants/index'
  end
end
