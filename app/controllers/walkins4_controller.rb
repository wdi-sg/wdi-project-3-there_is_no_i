class WalkinsController < ApplicationController
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
      determine_table(find_aval_tables, @walkin)
      # set table
      if @chosen_table
        @walkin.table_id = @chosen_table.id
        new_table_count(@chosen_table, @walkin.party_size)

        sms_awaiting(@walkin.name, @restaurant.name, @chosen_table.name)

        # ON HOLD? FOR RESTAURANT TO CONFIRM???
        # @walkin.status = 'dining'
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

  # Determin Table for New Customer
  def determine_table(aval_tables, walkin_person)
    block = 2.hours
    r_start_time = Time.now
    r_end_time = r_start_time + block
    date = r_start_time.strftime('%Y-%m-%d')

    # New Method
    # 1) @avail tables
    # 2) Find Blocked tables of blocked reservations
    # 3) Filter off tables from blocked
    # 4) Filter off tables of capacity_total
    # 5) sort
    # 6) Choose

    all_reservations = Reservation.where(restaurant_id: params[:restaurant_id]).where('DATE(start_time) = ?', date)

    affecting_reservations = all_reservations.where('start_time < ?', r_end_time - block).or(all_reservations.where('end_time > ?', r_start_time)).to_a

    affected_tables = []
    affecting_reservations.each do |reservation|
      affected_tables.push(Table.where('id = ?', reservation.table_id))
    end

    # p '===Tables AFFECTED by Reservations==='
    # p affected_tables

    unless affected_tables.empty?
      affected_tables.map do |table|
        # p '====Table Affected ID==='
        # p table[0].id
        table[0].id
      end
    end

    aval_tables.select do |table|
      affected_tables.exclude?(table[:id])
    end

    # p '====REMAINING AVALABLE TABLES====='
    # p aval_tables

    filtered_aval_tables = []
    aval_tables.each do |table|
      if table.capacity_total >= walkin_person.party_size
        filtered_aval_tables.push(table)
      end
    end

    filtered_aval_tables.sort_by!(&:capacity_total)

    # p '====FILTERED TABLES BY CAPACITY====='
    # p filtered_aval_tables

    @chosen_table = filtered_aval_tables[0]
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
