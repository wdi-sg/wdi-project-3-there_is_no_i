module MenuItemsHelper
  def formatPrice(price)
    number_to_currency(price, precision: 2, locale: :en)
  end
end
