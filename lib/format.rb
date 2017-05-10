module Format
  def formatDate(date)
    ampm = date.localtime.strftime('%H').to_i < 12 ? 'am' : 'pm'
    x = (date - DateTime.now)/(60*60*24)
    y = x >= 1 ? number_with_precision(x, precision: 0).to_str + ' days' : number_with_precision((x * 24), precision: 0).to_str + ' hours'
    date.localtime.strftime('%A %d %B %Y %l:%M ') + ampm + ' (in ' + y + ')'
  end

  def formatOrderDate(date)
    ampm = date.localtime.strftime('%H').to_i < 12 ? 'am' : 'pm'
    x = (date - DateTime.now)/(60*60*24)
    date.localtime.strftime('%d %B %y %l:%M ') + ampm
  end

  def formatInvoiceDate(date)
    x = (date - DateTime.now)/(60*60*24)
    date.localtime.strftime('%d %B %y')
  end

  def showTotalPrice(menu_items)
    menu_items.inject(0.0) { |result, item| result + item.price }
  end

  def formatPrice(price)
    number_to_currency(price, precision: 2, locale: :en)
  end

  def formatPhone (phone)
    number_to_phone(phone.to_i, :country_code => 65, :pattern => /(\d{4})(\d{4})$/, :delimiter => ' ')
  end

  def formatMenuItems(invoice)
    new_obj = {}
    orders_array = []
    invoice.orders.map{|order| order.menu_item.name }.each do |item|
      new_obj[item] == nil ? new_obj[item] = 1 : new_obj[item] += 1
    end
    new_obj.each do |key, value|
      orders_array << [key, value]
    end
    orders_array
  end

  def correctStartTime(order)
    # if takeaway return takeaway_time
    if order.invoice.takeaway_time
      order.invoice.takeaway_time
    # if reservation/queuing
    elsif order.invoice.reservation_id
      # if reservation return reservation start_time
      if order.invoice.reservation.status == 'reservation'
        order.invoice.reservation.start_time
      # if queuing/awaiting return estimated start_time
      else
        checked_queue_number = order.invoice.reservation.queue_number
        first_queue_number = Reservation.where(restaurant_id: @restaurant.id).where(status: ['queuing', 'awaiting']).count > 0 ? Reservation.where(restaurant_id: @restaurant.id).where(status: ['queuing', 'awaiting']).order('queue_number ASC').first.queue_number : checked_queue_number
        DateTime.now + ((checked_queue_number - first_queue_number) * 5).minutes
      end
    # if local order return created_at
    else
      order.created_at
    end
  end

  def allOrdersAreCompleted(invoice)
    done = true
    invoice.orders.each do |order|
      done = false if !order.time_end
    end
    done
  end
end
