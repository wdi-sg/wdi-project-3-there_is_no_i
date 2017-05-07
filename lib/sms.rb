module Sms
  def sms_awaiting(walkin_name, restaurant_name, chosen_table_name)
    p "SMS: Dear #{walkin_name}, your reservation at #{restaurant_name} is ready. Please proceed to table: #{chosen_table_name}"
  end

  def sms_queue(walkin, restaurant, queue_ahead)
    if queue_ahead == 0
      p "SMS: Dear #{walkin.name}, your reservation at #{restaurant.name} has been recorded. You are next in line for a party of #{walkin.party_size}. You may start placing your orders at https://locavorusrex.herokuapp.com/restaurants/#{restaurant.id}/menu_items"
    else
      p "SMS: Dear #{walkin.name}, your reservation at #{restaurant.name} has been recorded. There is/are #{queue_ahead} customer(s) ahead of you in the queue. You may start placing your orders at https://locavorusrex.herokuapp.com/restaurants/#{restaurant.id}/menu_items"
    end
  end
end
