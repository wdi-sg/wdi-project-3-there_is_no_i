module RestaurantsHelper
  def formatPhone (phone)
    number_to_phone(phone.to_i, :country_code => 65, :pattern => /(\d{4})(\d{4})$/, :delimiter => ' ')
  end
end
