class WalkinsController < ApplicationController
  before_action :set_restaurant, only: %i[index new main_create create public_new public_create public_show edit update destroy]
  before_action :set_walkin, only: %i[show edit update destroy]
  # before_action :find_queue_number, only: %i[create]
  helper WalkinHelper

  def index
    @walkins = Reservation.where(restaurant_id: params[:restaurant_id], status: 'queuing')
  end

  def create
    main_create(walkin_params)
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
    main_create(public_params)
    set_walkin_user(@walkin)
    find_aval_tables
    if @aval_tables.length > 0
      determine_table(@aval_tables, @walkin)
# ====================================
# CHANGE THIS ONCE determine_table IS SETTLED
      # @walkin.status = 'queuing'
      # if @walkin.save!
      #   redirect_to restaurant_public_path(@restaurant)
      # else
      #   render :public_new
      # end
# ====================================
      if @chosen_table
        @walkin.table_id = @chosen_table.id
        # CHANGE TABLE CURRENT CAPACITY !!!!
        change_table_status(@chosen_table, @walkin.party_size)
        @walkin.status = 'dining'
        if @walkin.save!
          redirect_to restaurant_public_path(@restaurant)
        else
          render :public_new
        end
      else
        @walkin.status = 'queuing'
        if @walkin.save!
          redirect_to restaurant_public_path(@restaurant)
        else
          render :public_new
        end
      end
    else
      @walkin.status = 'queuing'
      if @walkin.save!
        redirect_to restaurant_public_path(@restaurant)
      else
        render :public_new
      end
    end
  end

  def public_new
    @walkin = Reservation.new
    render 'layouts/public_walkin_new', :layout => false
  end

  def public_show
    render 'layouts/public_walkin', :layout => false
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

  def set_walkin_user(walkin)
    user = User.where(phone: walkin.phone)
    if user.count == 1
      walkin.user_id = user.pluck(:id)[0]
      walkin.name = user.pluck(:name)[0]
      walkin.email = user.pluck(:email)[0]
    # NEED TO CHECK IF CUSTOMER SUBMIT MULTIPLE TIMES --> Change!
    # elsif (user.count > 1 && walkin.phone)
    #   walkin.name = 'Walk in Customer (WARNING! Duplicate User number)'
    else
      walkin.name = 'Walk in Customer (Mobile Sign in)'
    end
  end

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def find_queue_number
    set_restaurant
    @restaurant.next_queue_number
  end

  def set_restaurant_queue
    set_restaurant
    @restaurant.next_queue_number += 1
    @restaurant.save
  end

  def set_walkin
    @walkin = Reservation.find(params[:id])
  end

  def main_create(params)
    @walkin = Reservation.new(params)
    @walkin.restaurant_id = @restaurant.id
    @walkin.queue_number = find_queue_number
    set_restaurant_queue
  end

  def find_aval_tables
    set_restaurant
    @aval_tables = Table.where(restaurant_id: @restaurant.id).where('capacity_current = ?', 0)
  end

  def determine_table(aval_tables, walkin_person)
    block = 2.hours
    r_start_time = Time.now
    r_end_time = r_start_time + block
    date = r_start_time.strftime("%Y-%m-%d")

    # This only shows reservations (not tables avail)
    all_reservations = Reservation.where(restaurant_id: params[:restaurant_id]).where("DATE(start_time) = ?", date)

    # Q: If there are no reservations, there are no tables?
    # all_avail_reservations = all_reservations.where("start_time >= ?", r_end_time).or(all_reservations.where("end_time <= ?", r_start_time)).to_a

    #New Method
    # 1) @avail tables
    # 2) Find Blocked tables of blocked reservations
    # 3) Filter off tables from blocked
    # 4) Filter off tables of capacity_total
    # 5) sort
    # 6) Choose

    affecting_reservations = all_reservations.where("start_time < ?", r_end_time - block).or(all_reservations.where("end_time > ?", r_start_time)).to_a

    affected_tables = []
    affecting_reservations.each do |reservation|
      affected_tables.push(Table.where("table_id = ?", reservation.table_id))
    end
    
    p '===AFFECTED==='
    p affected_tables

    if affected_tables.length > 0
      affected_tables.map do |table|
        table.id
      end
    end

    aval_tables.select do |table|
      affected_tables.exclude?(table[:id])
    end

    p '====AVAL TABLES====='
    p aval_tables

    filtered_aval_tables = []
    aval_tables.each do |table|
      if table.capacity_total >= walkin_person.party_size
        filtered_aval_tables.push(table)
      end
    end

    filtered_aval_tables.sort_by! {|table| table.capacity_total }

    p '====FILTERED TABLES====='
    p filtered_aval_tables

    @chosen_table = filtered_aval_tables[0]
  end

  def change_table_status(table, filled)
    table.capacity_current = filled
    table.save!
  end

  def public_params
    params.require(:reservation).permit(:phone, :party_size)
  end

  def walkin_params
    params.require(:reservation).permit(:name, :phone, :email, :party_size, :special_requests, :status)
  end
end