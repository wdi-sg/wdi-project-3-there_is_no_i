class WalkinsController < ApplicationController
  include FindingTableLogic
  include SendTwilio
  before_action :authenticate_user!, except: [:new]
  before_action :set_restaurant, only: %i[index new create_walkin create public_new public_create public_save public_show edit update destroy notify]
  before_action :set_walkin, only: %i[show edit update destroy]
  before_action :set_duration, only: [:create, :public_create, :update]
  helper WalkinHelper

  def index
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb "Back to restaurant", restaurant_path(@restaurant)
    @walkins = Reservation.where(restaurant_id: params[:restaurant_id], status: 'queuing').or(Reservation.where(restaurant_id: params[:restaurant_id], status: 'awaiting')).or(Reservation.where(restaurant_id: params[:restaurant_id], status: 'reservation'))
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
    create_walkin(public_params)

    user_reservations = Reservation.where(restaurant_id: @restaurant.id).where(phone: @walkin.phone)
    # Check for multiple entries
    if user_reservations.where(status: 'reservation').or(user_reservations.where(status: 'queuing')).or(user_reservations.where(status: 'awaiting')).or(user_reservations.where(status: 'dining')).count > 0

      @walkin.destroy
      flash['alert'] = 'Error. This is a duplicated entry. Please contact us if otherwise.'
      redirect_to restaurant_new_public_path(@restaurant)

    else
      recommended_table = determine_table(@restaurant, find_aval_tables(@restaurant), @walkin, Time.now, @est_duration)

      if recommended_table
        # Give customer a table if there is one
        update_table_count(recommended_table, @walkin.party_size)

        # Update as 'awating' here and send sms if automated
        update_customer(@walkin, recommended_table, 'queuing', Time.now, Time.now + @est_duration)

        # WHEN UPDATE TO AWATING, ASK IF OK TO SEND SMS, THEN NOTIFY?
        sms_queue(@walkin, Reservation.where(restaurant_id: params[:restaurant_id]).where('status = ?', 'queuing').count)

        public_save(@walkin)
      else
        # Queue customer if there is no table
        update_customer(@walkin, nil, 'queuing', nil, nil)

        sms_queue(@walkin, Reservation.where(restaurant_id: params[:restaurant_id]).where('status = ?', 'queuing').count)

        public_save(@walkin)
      end
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

  # def show; end

  def update
    if params[:reservation][:status] == 'cancelled'
      @walkin.status = 'cancelled'
      @walkin.table.capacity_total = 0
      @walkin.table.save
      update_save
    elsif params[:reservation][:status] == 'reservation'
      redirect_to restaurant_walkins_path(@restaurant)
    elsif params[:reservation][:status] == 'queuing'
      @walkin.party_size = params[:reservation][:party_size]
      update_save
    elsif params[:reservation][:status] == 'awaiting'
      old_start_time = @walkin.start_time
      old_table_id = @walkin.table_id
      old_party_size = @walkin.party_size

      @walkin.start_time = nil
      @walkin.end_time = nil
      # @walkin.table_id = params[:reservation][:table_id]
      @walkin.party_size = params[:reservation][:party_size]
      @walkin.save

      table_if_possible = determine_table(@restaurant, [@walkin.table], @walkin, Time.now, @est_duration)

      if table_if_possible
        @walkin.start_time = Time.now
        @walkin.end_time = Time.now + @est_duration
        @walkin.status = params[:reservation][:status]
        sms_awaiting(@walkin)
        update_save
      else
        @walkin.start_time = old_start_time
        @walkin.end_time = old_start_time + @est_duration
        @walkin.table_id = old_table_id
        @walkin.party_size = old_party_size
        @walkin.save
        flash['alert'] = 'Error. New parameters are not permitted.'
        redirect_to restaurant_edit_walkin_path(@restaurant, @walkin)
      end

    elsif params[:reservation][:status] == 'dining'
      # Check if table is empty
      if @walkin.table.capacity_total > 0
        flash['alert'] = 'Unable to commit. There are currently customers at the table.'
        render :edit
      else
        @walkin.status = 'dining'
        update_save
      end
    end
  end

  def update_save
    if @walkin.save!
      redirect_to restaurant_walkins_path(@restaurant)
    else
      flash['alert'] = 'Error. Unable to save update.'
      render :edit
    end
  end

  # def destroy
  #   @walkin.destroy
  #   redirect_to restaurant_walkins_path(@restaurant)
  # end

  def notify
    if Reservation.find(params[:id]) && Restaurant.find(params[:restaurant_id])
      walkin = Reservation.find(params[:id])
      # restaurant = Restaurant.find(params[:restaurant_id])
      walkin.status = 'awaiting'
      if walkin.save!
        sms_awaiting(walkin)
        redirect_to restaurant_walkins_path(params[:restaurant_id])
      else
        flash['alert'] = 'Error 500. Unable to update status'
        redirect_to restaurant_walkins_path(params[:restaurant_id])
      end
    else
      flash['alert'] = 'Error. Unable to find reservation or restaurant in DB.'
      redirect_to restaurant_walkins_path(params[:restaurant_id])
    end
  end

  def requeue
    if Reservation.find(params[:id]) && Restaurant.find(params[:restaurant_id])
      walkin = Reservation.find(params[:id])
      walkin.queue_number = walkin.restaurant.next_queue_number
      set_next_queue_number(walkin.restaurant)
      if walkin.save!
        sms_requeue(walkin)
        redirect_to restaurant_walkins_path(params[:restaurant_id])
      else
        flash['alert'] = 'Error 500. Unable to update'
        redirect_to restaurant_walkins_path(params[:restaurant_id])
      end
    else
      flash['alert'] = 'Error. Unable to find reservation or restaurant in DB.'
      redirect_to restaurant_walkins_path(params[:restaurant_id])
    end
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

  def update_customer(customer, recommended_table, new_status, new_start_time, new_end_time)
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
  end

  def public_params
    params.require(:reservation).permit(:phone, :party_size)
  end

  def walkin_params
    params.require(:reservation).permit(:name, :phone, :email, :party_size, :special_requests, :status)
  end
end
