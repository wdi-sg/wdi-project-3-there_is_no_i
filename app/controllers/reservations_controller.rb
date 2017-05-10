class ReservationsController < ApplicationController
  include AuthenticateRestaurantUser
  include FindingTableLogic
  include SendEmail
  before_action :authenticate_user!, except: [:create, :new]
  before_action :set_restaurant_id
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]
  before_action :check_user_is_part_of_restaurant, except: [:create, :new]
  before_action :check_user_is_part_of_reservation, only: [:show, :edit, :update, :delete]

  before_action :set_duration, only: [:create, :update]
  helper ReservationsHelper

  def index
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb @restaurant.name, restaurant_path(@restaurant)
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
    elsif Reservation.where(email: params[:reservation][:email]).where('start_time < ?', r_start_time + @est_duration).where('end_time > ?', r_start_time).count > 0
      flash['alert'] = "Duplicated Entry Detected. Cannot create another entry within the #{@est_duration / 3600} hours block of the previous entry."
      render :new
    else
      new_res = Reservation.new()
      if params[:reservation][:name]
        new_res[:name] = params[:reservation][:name]
        new_res[:email] = params[:reservation][:email]
        new_res[:phone] = params[:reservation][:phone]
      else
        new_res[:user_id] = current_user.id
        new_res[:name] = current_user.name
        new_res[:email] = current_user.email
        new_res[:phone] = current_user.phone
      end
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

          if new_res.email == nil or new_res.email.length < 2
            flash['alert'] = "Successful reservation for #{new_res[:party_size]} on #{new_res[:start_time]}."
            redirect_to restaurant_path(params[:restaurant_id])

          else
            subject = "Reservation at #{new_res.restaurant.name} on #{new_res.start_time} for #{new_res.party_size}"

            body = "Dear #{new_res.name}, \nYour reservation at #{new_res.restaurant.name} on #{new_res.start_time} for a table of #{new_res.party_size} has been recorded. You may place an advance order at https://locavorusrex.herokuapp.com/reservations . Thank you and see you soon! \nBest regards, \n#{new_res.restaurant.name} \n \n \nPowered by Locavorus"

            send_email(new_res.name, new_res.email, subject, body)

            flash['alert'] = "Successful reservation for #{new_res[:party_size]} on #{new_res[:start_time]}."
            redirect_to restaurant_path(params[:restaurant_id])
          end

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
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb @restaurant.name, restaurant_path(@restaurant)
    add_breadcrumb "Reservations", restaurant_reservations_path(@restaurant)
    @table_options = @restaurant.tables.map do |table|
      [table.name, table.id]
    end
  end

  def new
    if !current_user
      flash['alert'] = 'Please login or register before making a reservation.'
      redirect_to new_user_session_path
    end
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb @restaurant.name, restaurant_path(@restaurant)
    add_breadcrumb "Reservations", restaurant_reservations_path(@restaurant)
  end

  def show
    add_breadcrumb "Restaurants", :restaurants_path
    add_breadcrumb @restaurant.name, restaurant_path(@restaurant)
    add_breadcrumb "Reservations", restaurant_reservations_path(@restaurant)
  end

  def update
    old_start_time = @reservation.start_time
    p 'TROUBLESHOOT'
    p @reservation.start_time.hour

    r_start_time =  Time.zone.local( params[:datetime]["date(1i)"].to_i, params[:datetime]["date(2i)"].to_i, params[:datetime]["date(3i)"].to_i, params[:datetime]["time(4i)"].to_i, params[:datetime]["time(5i)"].to_i, 0)

    if r_start_time < Time.now
      flash['alert'] = 'Error. Cannot reserve a timeslot from the past. Please check input parameters.'
      @table_options = @restaurant.tables.map do |table|
        [table.name, table.id]
      end
      render :edit
    elsif r_start_time < Time.now + @est_duration
      flash['alert'] = "Cannot make a reservation within #{@est_duration} hours from now."
      @table_options = @restaurant.tables.map do |table|
        [table.name, table.id]
      end
      render :edit
    else
      @reservation.start_time = nil
      @reservation.save

      validate_update = determine_table(@restaurant, [Table.find(params[:reservation][:table_id])], @reservation, r_start_time, @est_duration)

      if validate_update
        @reservation.start_time = r_start_time
        @reservation.end_time = @reservation.start_time + @est_duration

        if @reservation.update(reservation_params)

          if @reservation.email == nil or @reservation.email.length < 2
            flash['alert'] = 'Successfully updated reservation'
            redirect_to restaurant_reservations_path(@restaurant)

          else
            subject = "Reservation at #{@reservation.restaurant.name} on #{@reservation.start_time} for #{@reservation.party_size}"

            body = "Dear #{@reservation.name}, \nYour reservation at #{@reservation.restaurant.name} on #{@reservation.start_time} for a table of #{@reservation.party_size} has been updated. You may place an advance order at https://locavorusrex.herokuapp.com/reservations . Thank you and see you soon! \nBest regards, \n#{@reservation.restaurant.name} \n \n \nPowered by Locavorus"

            p body

            send_email(@reservation.name, @reservation.email, subject, body)

            flash['alert'] = 'Successfully updated reservation'
            redirect_to restaurant_reservations_path(@restaurant)
          end

        else
          @reservation.start_time = old_start_time
          @reservation.save
          flash['alert'] = 'Error. Please check input parameters.'
          @table_options = @restaurant.tables.map do |table|
            [table.name, table.id]
          end
          render :edit
          # redirect_to edit_restaurant_reservation_path(@restaurant, @reservation)
        end
      else
        @reservation.start_time = old_start_time
        @reservation.save
        flash['alert'] = 'Not possible to update changes. Please try again with a different parameter.'
        @table_options = @restaurant.tables.map do |table|
          [table.name, table.id]
        end
        render :edit
        # redirect_to edit_restaurant_reservation_path(@restaurant, @reservation)
      end
    end
  end

  def destroy
    # ERROR HERE: INVALID FOREIGN KEY for Invoices
    all_invoices = Invoice.where(reservation_id: @reservation.id)
    if all_invoices
      all_invoices.each do |invoice|
        invoice.update(reservation_id: nil)
      end
    end
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
