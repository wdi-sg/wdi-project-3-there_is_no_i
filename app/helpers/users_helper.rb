module UsersHelper
  def formatDate(date)
    ampm = date.localtime.strftime('%H').to_i < 12 ? 'am' : 'pm'
    x = (date - DateTime.now)/(60*60*24)
    y = x >= 1 ? number_with_precision(x, precision: 0).to_str + ' days' : number_with_precision((x * 24), precision: 0).to_str + ' hours'
    date.localtime.strftime('%A %d %B %Y %l:%M ') + ampm + ' (in ' + y + ')'
  end

  def formatInvoiceDate(date)
    x = (date - DateTime.now)/(60*60*24)
    date.localtime.strftime('%d %B %y')
  end
end