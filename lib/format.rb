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
end
