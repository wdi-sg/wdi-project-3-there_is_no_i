class WalkinsController < ApplicationController
  include FindingTableLogic
  before_action :authenticate_user!, except: [:new]
  before_action :set_restaurant, only: %i[index new create_walkin create public_new public_create public_show edit update destroy]
  before_action :set_walkin, only: %i[show edit update destroy]
  helper WalkinHelper

  def index
    @walkins = Reservation.where(restaurant_id: params[:restaurant_id], status: 'queuing')
  end

  def create
    create_walkin(walkin_params)
    if @walkin.save!
      redirect_to restaurant_walkins_path(@restaurant)
    else
      render :new
    end
  end

  def new
    @walkin = Reservation.new
  end

  def public_create
    create_walkin(public_params)
    if !find_aval_tables.empty?
      determine_table(set_restaurant, find_aval_tables, @walkin, Time.now, 2.hours)
      if @chosen_table
        @walkin.table_id = @chosen_table.id
        new_table_count(@chosen_table, @walkin.party_size)
        sms_awaiting(@walkin.name, @restaurant.name, @chosen_table.name)
        @walkin.status = 'awaiting'
        @walkin.start_time = Time.now
        @walkin.end_time = Time.now + 2.hours
        public_save(@walkin)
      else
        sms_queue(@walkin.name, @restaurant.name, Reservation.where(restaurant_id: params[:restaurant_id]).where('status = ?', 'queuing').count)
        @walkin.status = 'queuing'
        public_save(@walkin)
      end
    else
      sms_queue(@walkin.name, @restaurant.name, Reservation.where(restaurant_id: params[:restaurant_id]).where('status = ?', 'queuing').count)
      @walkin.status = 'queuing'
      public_save(@walkin)
    end
  end

  def public_save(walkin)
    if walkin.save!
      redirect_to restaurant_public_path(@restaurant)
    else
      render :public_new
    end
  end

  def public_new
    @walkin = Reservation.new
    render 'layouts/public_walkin_new', layout: false
  end

  def public_show
    render 'layouts/public_walkin', layout: false
  end

  def edit; end

  def show; end

  def update
    if @walkin.update(walkin_params)
      redirect_to restaurant_walkins_path(@restaurant)
    else
      render :edit
    end
  end

  def destroy
    @walkin.destroy
    redirect_to restaurant_walkins_path(@restaurant)
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def find_queue_number
    set_restaurant
    @restaurant.next_queue_number
  end

  def set_walkin
    @walkin = Reservation.find(params[:id])
  end

  # Create Walkin Person's Restaurant & Queue Number
  def create_walkin(params)
    @walkin = Reservation.new(params)
    @walkin.restaurant_id = @restaurant.id
    @walkin.queue_number = find_queue_number
    find_user(@walkin)
    set_next_queue_number
  end

  def set_next_queue_number
    set_restaurant
    @restaurant.next_queue_number += 1
    @restaurant.save
  end

  # Set Details of Walkin User
  def find_user(walkin)
    user = User.where(phone: walkin.phone)
    if user.count == 1
      walkin.user_id = user.pluck(:id)[0]
      walkin.name = user.pluck(:name)[0]
      walkin.email = user.pluck(:email)[0]
      walkin.save!
    # NEED TO CHECK IF CUSTOMER SUBMIT MULTIPLE TIMES --> Change!
    # elsif (user.count > 1 && walkin.phone)
    #   walkin.name = 'Walk in Customer (WARNING! Duplicate User number)'
    else
      walkin.name = 'Walk in Customer'
    end
  end

  # Find Available Tables For New Customer
  def find_aval_tables
    set_restaurant
    @aval_tables = Table.where(restaurant_id: @restaurant.id).where('capacity_current = ?', 0)
  end

  # Change Table's new capacity once customer is assigned
  def new_table_count(table, filled)
    table.capacity_current = filled
    table.save!
  end

  def sms_awaiting(walkin_name, restaurant_name, chosen_table_name)
    p "SMS: Dear #{walkin_name}, your reservation at #{restaurant_name} is ready. Please proceed to table: #{chosen_table_name}"
  end

  def sms_queue(walkin_name, restaurant_name, queue_ahead)
    p "SMS: Dear #{walkin_name}, your reservation at #{restaurant_name} is noted. There are #{queue_ahead} customers ahead of you."
  end

  def public_params
    params.require(:reservation).permit(:phone, :party_size)
  end

  def walkin_params
    params.require(:reservation).permit(:name, :phone, :email, :party_size, :special_requests, :status)
  end
end
