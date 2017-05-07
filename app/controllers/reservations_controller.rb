class ReservationsController < ApplicationController
  include AuthenticateRestaurantUser
  include FindingTableLogic
  before_action :authenticate_user!, except: [:create, :new, :show]
  before_action :set_restaurant_id
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]
  before_action :check_user_is_part_of_restaurant, except: [:create, :new, :show]
  before_action :check_user_is_part_of_reservation, only: [:show]
  before_action :set_duration, only: [:create, :update]
  helper ReservationsHelper

  def index
    @restaurant_id = params[:restaurant_id]
    if request.fullpath == "/restaurants/#{@restaurant_id}/reservationss?name=sort"
      @reservations = Reservation.where(restaurant_id: params[:restaurant_id]).order('name ASC')
    elsif request.fullpath == "/restaurants/#{@restaurant_id}/reservations?pax=sort"
      @reservations = Reservation.where(restaurant_id: params[:restaurant_id]).order(:party_size)
    elsif request.fullpath == "/restaurants/#{@restaurant_id}/reservations?date=sort"
      @reservations = Reservation.where(restaurant_id: params[:restaurant_id]).order(:start_time)
    else
      @reservations = Reservation.where(restaurant_id: params[:restaurant_id]).order('start_time ASC')
    end
  end

  def create
    r_start_time =  Time.zone.local( params[:reservation]["date(1i)"].to_i, params[:reservation]["date(2i)"].to_i, params[:reservation]["date(3i)"].to_i, params[:reservation]["time(4i)"].to_i, params[:reservation]["time(5i)"].to_i, 0)

    if r_start_time < Time.now
      flash['alert'] = 'Error. Cannot reserve a timeslot from the past. Please check input parameters.'
      render :new
    elsif r_start_time < Time.now + @reservation_allowance.hours
      flash['alert'] = "Cannot make a reservation within #{@reservation_allowance} hours from now."
      render :new
      # VALIDATE: Check for multiple entries
      # reservation where same email, date
    else
      new_res = Reservation.new()
      new_res[:name] = params[:reservation][:name]
      new_res[:email] = params[:reservation][:email]
      new_res[:phone] = params[:reservation][:phone]
      new_res[:party_size] = params[:reservation][:party_size]
      new_res[:restaurant_id] = params[:restaurant_id]

      avail_tables = Table.where(restaurant_id: @restaurant.id)

      recommended_table = determine_table(@restaurant, avail_tables, new_res, r_start_time, @est_duration)

      p '===RECOMMENDED TABLE==='
      p recommended_table

      if recommended_table
        new_res[:start_time] = r_start_time
        new_res[:end_time] = r_start_time + 2.hours
        new_res[:table_id] = recommended_table.id
        new_res[:status] = 'reservation'
        if new_res.save!
          # Redirect to success page & SEND EMAIL
          redirect_to restaurant_path(params[:restaurant_id])
        else
          flash['alert'] = 'Error. Please check input parameters.'
          render :new
        end
      else
        flash['alert'] = 'There are no tables available at that time. Please try again with a different timeslot.'
        render :new
      end
    end
  end

  def edit
    @table_options = @restaurant.tables.map do |table|
      [table.name, table.id]
    end
    @hour = @reservation.start_time.hour
    @minute = @reservation.start_time.min
  end

  def new
  end

  def show
  end

  def update
    old_start_time = @reservation.start_time
    p 'TROUBLESHOOT'
    p @reservation.start_time.hour

    r_start_time =  Time.zone.local( params[:datetime]["date(1i)"].to_i, params[:datetime]["date(2i)"].to_i, params[:datetime]["date(3i)"].to_i, params[:datetime]["time(4i)"].to_i, params[:datetime]["time(5i)"].to_i, 0)

    if r_start_time < Time.now
      flash['alert'] = 'Error. Cannot reserve a timeslot from the past. Please check input parameters.'
      render :new
    elsif r_start_time < Time.now + @reservation_allowance.hours
      flash['alert'] = "Cannot make a reservation within #{@reservation_allowance} hours from now."
      render :new
    else
      @reservation.start_time = nil
      @reservation.save

      validate_update = determine_table(@restaurant, [Table.find(params[:reservation][:table_id])], @reservation, r_start_time, @est_duration)

      if validate_update
        @reservation.start_time = r_start_time
        @reservation.end_time = @reservation.start_time + @est_duration

        if @reservation.update(reservation_params)
          redirect_to restaurant_reservations_path(@restaurant)
        else
          @reservation.start_time = old_start_time
          @reservation.save
          flash['alert'] = 'Error. Please check input parameters.'
          redirect_to edit_restaurant_reservation_path(@restaurant, @reservation)
        end
      else
        @reservation.start_time = old_start_time
        @reservation.save
        flash['alert'] = 'Not possible to update changes. Please try again with a different parameter.'
        redirect_to edit_restaurant_reservation_path(@restaurant, @reservation)
      end
    end
  end

  def destroy
    # ERROR HERE: INVALID FOREIGN KEY for Invoices
    if @reservation.destroy!
      redirect_to restaurant_reservations_path(@restaurant)
    else
      render :new
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:name, :email, :phone, :party_size, :start_time, :status, :table_id, :special_requests)
  end

  def check_user_is_part_of_reservation
    if current_user[:id] != @reservation[:user_id] && !current_user.restaurants.include?(@reservation.restaurant)
      flash['alert'] = 'You do not have permission to access that page'
      redirect_to edit_user_registration_path
    end
  end
end
