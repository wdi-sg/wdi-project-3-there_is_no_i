class WalkinsController < ApplicationController
  include FindingTableLogic
  before_action :authenticate_user!, except: [:new]
  before_action :set_restaurant, only: %i[index new create_walkin create public_new public_create public_save public_show edit update destroy]
  before_action :set_walkin, only: %i[show edit update destroy]
  helper WalkinHelper

  def index
    @walkins = Reservation.where(restaurant_id: params[:restaurant_id], status: 'queuing')
  end

  # def create
  #   create_walkin(walkin_params)
  #   if @walkin.save!
  #     redirect_to restaurant_walkins_path(@restaurant)
  #   else
  #     render :new
  #   end
  # end
  #
  # def new
  #   @walkin = Reservation.new
  # end

  def public_create
    est_duration = 2.hours

    create_walkin(public_params)

    recommended_table = determine_table(@restaurant, find_aval_tables(@restaurant), @walkin, Time.now, est_duration)

    if recommended_table

      update_table_count(recommended_table, @walkin.party_size)

      update_new_customer(@walkin, recommended_table, 'awaiting', Time.now, Time.now + est_duration)

      recommended_table.start_time = Time.now
      recommended_table.end_time = Time.now + est_duration

      sms_awaiting(@walkin.name, @restaurant.name, recommended_table.name)
    else
      #CHANGE TO BLANK


      # Set the EST TIME / Table OR recommend further action
      # sort by end_time
      reservations_by_endtime = Reservation.where(restaurant_id: @restaurant.id).where.not(status: 'checked_out').where.not(status: 'cancelled').where.not(end_time: nil).sort_by {|reservation| reservation[:end_time]}

      p 'TABLES BY END TIME'
      p reservations_by_endtime

      i = 0
      while recommended_table == nil
      recommended_table = determine_table(@restaurant, Table.where(restaurant_id: @restaurant.id), @walkin, reservations_by_endtime[i].end_time, est_duration)
      i += 1
      end

      # FIX NOT ACCURATE END TIME
      new_time = Reservation.where(table_id: recommended_table.id).sort_by{|reservation| reservation[:end_time]}[0].end_time

      # recommend change table settings? change minimum / split / join
      update_new_customer(@walkin, recommended_table, 'queuing', new_time, new_time + est_duration)

      sms_queue(@walkin, @restaurant, Reservation.where(restaurant_id: params[:restaurant_id]).where('status = ?', 'queuing').count)
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

  def set_walkin
    @walkin = Reservation.find(params[:id])
  end

  # Create Walkin Person's Restaurant & Queue Number
  def create_walkin(params)
    @walkin = Reservation.new(params)
    @walkin.restaurant_id = @restaurant.id
    @walkin.queue_number = @restaurant.next_queue_number
    find_user(@walkin)
    set_next_queue_number(@restaurant)
  end

  def set_next_queue_number(restaurant)
    restaurant.next_queue_number += 1
    restaurant.save
  end

  # Set Details of Walkin User
  def find_user(walkin)
    user = User.where(phone: walkin.phone)
    # NEED TO CHECK IF CUSTOMER SUBMIT MULTIPLE TIMES --> Change!
    # elsif (user.count > 1 && walkin.phone)
    #   walkin.name = 'Walk in Customer (WARNING! Duplicate User number)'
    if user.count == 1
      walkin.user_id = user.pluck(:id)[0]
      walkin.name = user.pluck(:name)[0]
      walkin.email = user.pluck(:email)[0]
      walkin.save!
    else
      walkin.name = 'Customer'
    end
  end

  # Find Available Tables For New Customer
  def find_aval_tables(restaurant)
    aval_tables = Table.where(restaurant_id: restaurant.id).where('capacity_current = ?', 0)
  end

  # Change Table's new capacity once customer is assigned
  def update_table_count(table, filled)
    table.capacity_current = filled
    table.save!
  end

  def update_new_customer(customer, recommended_table, new_status, new_start_time, new_end_time)
    customer.status = new_status
    if recommended_table
      customer.table_id = recommended_table.id
    end
    if new_start_time
      customer.start_time = new_start_time
    end
    if new_end_time
      customer.end_time = new_end_time
    end
    public_save(customer)
  end

  def sms_awaiting(walkin_name, restaurant_name, chosen_table_name)
    p "SMS: Dear #{walkin_name}, your reservation at #{restaurant_name} is ready. Please proceed to table: #{chosen_table_name}"
  end

  def sms_queue(walkin, restaurant, queue_ahead)
    if queue_ahead == 1
      p "SMS: Dear #{walkin.name}, your reservation at #{restaurant.name} has been recorded. You are next in line for a party of #{walkin.party_size}. You may start placing your orders at localhost:3000/restaurants/#{restaurant.id}/menu_items"
    else
      p "SMS: Dear #{walkin.name}, your reservation at #{restaurant.name} has been recorded. There is/are #{queue_ahead - 1} customer(s) ahead of you. You may start placing your orders at localhost:3000/restaurants/#{restaurant.id}/menu_items"
    end
  end

  def public_params
    params.require(:reservation).permit(:phone, :party_size)
  end

  def walkin_params
    params.require(:reservation).permit(:name, :phone, :email, :party_size, :special_requests, :status)
  end
end
