class ReservationsController < ApplicationController
  before_action :set_restaurant, only: %i[new index show create edit update destroy]
  before_action :set_reservation, only: %i[show edit update destroy]
  # helper ReservationsHelper

  def index
    @reservations = Reservation.where(restaurant_id: params[:restaurant_id]).order('start_time ASC')
  end

  def create
    d = Time.parse(params[:reservation][:date])
    date = d.strftime("%Y-%m-%d")
    puts "DATE #{date}"
    day = d.strftime('%d')
    month = d.strftime('%m')
    year = d.strftime('%Y')
    t = Time.parse(params[:reservation][:time])
    start_time = t.change(day: day, month: month, year: year, offset: +0o000) - 8.hours
    puts "START TIME: #{start_time}"
    end_time = start_time + 2.hours
    party_size = params[:reservation][:party_size]

    # find all reservations from that restaurant on the date chosen by customer on the reservation form
    all_reservations = Reservation.where(restaurant_id: params[:restaurant_id]).where("DATE(start_time) = ?", date).to_a

    puts "ALL RESERVATIONS #{all_reservations}"
    start_times = []
    all_reservations.each do |item|
      start_times.push(item.start_time)
    end
    puts "START TIMES: #{start_times}"
    end_times = []
    all_reservations.each do |item|
      end_times.push(item.end_time)
    end
    puts "END TIMES: #{end_times}"

    $start_ok = 0
    $end_ok = 0
    start_times.each do |time|
      if time.between?(start_time, end_time) == false
        $start_ok = 'ok'
      end
    end

    end_times.each do |time|
      if time.between?(start_time, end_time) == false
        $end_ok = 'ok'
      end
    end

    if $start_ok == 'ok' && $end_ok == 'ok'
      # check availability of appropriate capacity tables and assign

      # find an array of tables in the restaurant that can match the party size
      avail_tables = Table.where(restaurant_id: params[:restaurant_id]).where("capacity_total >= ?", party_size)
    end


    new_res = {}
    new_res[:name] = params[:reservation][:name]
    new_res[:phone] = params[:reservation][:phone]
    new_res[:start_time] = start_time
    new_res[:end_time] = start_time + 2.hours
    new_res[:party_size] = params[:reservation][:party_size]
    new_res[:restaurant_id] = params[:restaurant_id]

    @reservation = Reservation.new(new_res)

    if @reservation.save
      redirect_to restaurant_path(params[:restaurant_id])
    else
      render :new
    end
  end

  def edit
  end

  def new
  end

  def show
  end

  def update
    if @reservation.update(reservation_params)
      redirect_to restaurant_reservations_path(@restaurant)
    else
      render :edit
    end
  end

  def destroy
    @reservation.destroy
    redirect_to restaurant_reservations_path(@restaurant)
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:name, :party_size, :start_time)
  end
end
