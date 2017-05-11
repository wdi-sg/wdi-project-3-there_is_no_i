class WalkinsController < ApplicationController
  include AuthenticateRestaurantUser
  include AddBreadcrumbs
  include FindingTableLogic
  include SendTwilio
  include Format
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :check_user_is_part_of_restaurant
  before_action :set_walkin, only: %i[show edit update destroy]
  before_action :set_duration
  helper WalkinHelper

  def index
    add_index_breadcrumbs
    @walkins = Reservation.where(restaurant_id: params[:restaurant_id], status: 'queuing').or(Reservation.where(restaurant_id: params[:restaurant_id], status: 'awaiting')).or(Reservation.where(restaurant_id: params[:restaurant_id], status: 'reservation'))
  end

  def create
    create_walkin(walkin_params)
    @walkin.status = 'queuing'
    if @walkin.save!
      redirect_to dashboard_path
    else
      render :new
    end
  end

  def new
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb @restaurant.name, restaurant_path(@restaurant)
    add_breadcrumb "View Current Queue", restaurant_walkins_path(@restaurant)
    @walkin = Reservation.new
  end

  def public_create
    create_walkin(public_params)

    user_reservations = Reservation.where(restaurant_id: @restaurant.id).where(phone: @walkin.phone)
    # Check for multiple entries
    if user_reservations.where(status: ['awaiting', 'queuing', 'dining']).count > 0

      @walkin.destroy
      flash['alert'] = 'This is a duplicated entry and is not permitted. Please contact us if otherwise.'
      redirect_to restaurant_new_public_path(@restaurant)

    elsif user_reservations.where(status: 'reservation').where('start_time < ?', Time.now + 2.hours).count > 0

      @walkin.destroy
      flash['alert'] = 'This entry is not permitted as you already have an upcoming reservation within 2 hours. Please contact us if otherwise.'
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
      walkin_name = walkin.name != nil ? walkin.name : ''
      walkin_phone = formatPhone(walkin.phone)
      walkin_start_time = walkin.start_time != nil ? formatOrderDate(walkin.start_time) : ''
      walkin_table_name = walkin.table != nil ? 'Table: ' + walkin.table.name : ''

      ActionCable.server.broadcast('room_channel', { walkin: walkin.id, queue_number: walkin.queue_number, name: walkin_name, phone: walkin_phone, party_size: walkin.party_size, start_time: walkin_start_time, table_name: walkin_table_name, restaurant: @restaurant.id} )

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

  # def edit; end

  # def show; end

  # def update; end

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
      walkin.status = 'awaiting'
      if walkin.save!
        sms_awaiting(walkin)
        flash['notice'] = "#{walkin.name} was notified"
        redirect_to dashboard_path
      else
        flash['alert'] = 'Error 500. Unable to update status'
        redirect_to dashboard_path
      end
    else
      flash['alert'] = 'Error. Unable to find reservation or restaurant in DB.'
      redirect_to dashboard_path
    end
  end

  def requeue
    if Reservation.find(params[:id]) && Restaurant.find(params[:restaurant_id])
      walkin = Reservation.find(params[:id])
      walkin.queue_number = walkin.restaurant.next_queue_number
      set_next_queue_number(walkin.restaurant)
      if walkin.save!
        sms_requeue(walkin)
        flash['alert'] = "#{walkin.name}(##{walkin.queue_number}) was requeued"
        redirect_to dashboard_path
      else
        flash['alert'] = 'Error 500. Unable to update'
        redirect_to dashboard_path
      end
    else
      flash['alert'] = 'Error. Unable to find reservation or restaurant in DB.'
      redirect_to dashboard_path
    end
  end

  def seated
    if Reservation.find(params[:id]) && Restaurant.find(params[:restaurant_id])
      diner = Reservation.find(params[:id])
      old_status = diner.status
      diner.status = 'dining'
      diner.start_time = Time.now
      diner.end_time = Time.now + @est_duration
      diner.table.capacity_current = diner.party_size
      diner.save!
      diner.table.save!
      if old_status == 'reservation'
        flash['notice'] = "#{diner.name}(Reservation ##{diner.id}) has checked into the restaurant"
        redirect_to dashboard_path
      else
        flash['notice'] = "#{diner.name}(##{diner.queue_number}) has checked into the restaurant"
        redirect_to dashboard_path
      end

    else
      flash['alert'] = 'Error. Unable to find reservation or restaurant in DB.'
      redirect_to dashboard_path
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
    if @walkin.phone
      find_user(@walkin)
    end
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
