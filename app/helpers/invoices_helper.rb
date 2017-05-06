module InvoicesHelper
  def formatInvoiceDate(date)
    ampm = date.localtime.strftime('%H').to_i < 12 ? 'am' : 'pm'
    x = (date - DateTime.now)/(60*60*24)
    date.localtime.strftime('%d %B %y %l:%M ') + ampm
  end

  def showTotalPrice(menu_items)
    menu_items.inject(0.0) { |result, item| result + item.price }
  end

  def formatPrice(price)
    number_to_currency(price, precision: 2, locale: :en)
  end
end
