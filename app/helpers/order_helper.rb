module OrderHelper
  def formatOrderDate(date)
    ampm = date.localtime.strftime('%H').to_i < 12 ? 'am' : 'pm'
    x = (date - DateTime.now)/(60*60*24)
    date.localtime.strftime('%d %B %y %l:%M ') + ampm
  end
end
