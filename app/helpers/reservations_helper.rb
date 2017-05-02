module ReservationsHelper
  def formatDate(date)
    ampm = date.strftime('%H').to_i < 12 ? 'am' : 'pm'
    x = ((date.to_i - DateTime.now.to_i)/(60*60*24)).to_s
    date.strftime('%A %d %B %Y %l:%M ' + ampm + ' (in ' + x + ' days)')
  end

  def formatPhone (phone)
    number_to_phone(phone.to_i, :country_code => 65, :pattern => /(\d{4})(\d{4})$/, :delimiter => ' ')
  end
end
