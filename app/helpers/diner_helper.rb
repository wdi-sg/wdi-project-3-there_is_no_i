module DinerHelper
  def formatDate(date)
    ampm = date.localtime.strftime('%H').to_i < 12 ? 'am' : 'pm'
    x = (date - DateTime.now)/(60*60*24)
    y = x >= 1 ? number_with_precision(x, precision: 0).to_str + ' days' : number_with_precision((x * 24), precision: 0).to_str + ' hours'
    date.localtime.strftime('%A %d %B %Y %l:%M ') + ampm + ' (in ' + y + ')'
  end

  def formatPhone (phone)
    number_to_phone(phone.to_i, :country_code => 65, :pattern => /(\d{4})(\d{4})$/, :delimiter => ' ')
  end
end
