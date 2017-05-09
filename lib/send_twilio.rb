module SendTwilio
  def send_message(recipient, message)
    twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
    twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']
    client = Twilio::REST::Client.new twilio_account_sid, twilio_auth_token
    client.account.messages.create(
      :from => "+61428086370", # My Twilio number <-- To be in .env
      :to => recipient,
      :body => message
    )
  end

  # SMS Templates
  def sms_awaiting(walkin)
    if walkin.phone != nil and walkin.phone != ''
      message = "Dear #{walkin.name}, your reservation at #{walkin.restaurant.name} is ready. Please proceed to table: #{walkin.table.name}"

      # send_message('+65' + walkin.phone, message)
    end
  end

  def sms_queue(walkin, queue_ahead)
    if walkin.phone != nil and walkin.phone != ''
      if queue_ahead == 0
        message = "Dear #{walkin.name}, your reservation at #{walkin.restaurant.name} has been recorded. Your queue number is #{walkin.queue_number}. You are next in line for a cover of #{walkin.party_size}. We will notify you again when your table is ready. In the meantime, you may start placing your orders at https://locavorusrex.herokuapp.com/restaurants/#{walkin.restaurant.id}/menu_items"

        # send_message('+65' + walkin.phone, message)

      elsif queue_ahead == 1
        message = "Dear #{walkin.name}, your reservation at #{walkin.restaurant.name} has been recorded. Your queue number is #{walkin.queue_number}. There is #{queue_ahead} customer ahead of you in the queue. We will notify you again when your table is ready. In the meantime, you may start placing your orders at https://locavorusrex.herokuapp.com/restaurants/#{walkin.restaurant.id}/menu_items"

        # send_message('+65' + walkin.phone, message)
      else
        message = "Dear #{walkin.name}, your reservation at #{walkin.restaurant.name} has been recorded. Your queue number is #{walkin.queue_number}. There are #{queue_ahead} customers ahead of you in the queue. We will notify you again when your table is ready. In the meantime, you may start placing your orders at https://locavorusrex.herokuapp.com/restaurants/#{walkin.restaurant.id}/menu_items"

        # send_message('+65' + walkin.phone, message)
      end
    end
  end

  def sms_send_back_queue(walkin)
    if walkin.phone != nil and walkin.phone != ''
      message = "Dear #{walkin.name}, your table at #{walkin.restaurant.name} has been reassigned. Your new queue number is #{walkin.queue_number}. We will notify you again when the next available table is ready. In the meantime, you may start placing your orders at https://locavorusrex.herokuapp.com/restaurants/#{walkin.restaurant.id}/menu_items"

      # send_message('+65' + walkin.phone, message)
    end
  end

  def sms_requeue(walkin)
    if walkin.phone != nil and walkin.phone != ''
      message = "Dear #{walkin.name}, you have been re-queued at #{walkin.restaurant.name}. Your new queue number is #{walkin.queue_number}. We will notify you again when your table is ready. In the meantime, you may start placing your orders at https://locavorusrex.herokuapp.com/restaurants/#{walkin.restaurant.id}/menu_items"

      # send_message('+65' + walkin.phone, message)
    end
  end

  def sms_cancelled(walkin)
    if walkin.phone != nil and walkin.phone != ''
      message = "Dear #{walkin.name}, your reservation at #{walkin.restaurant.name} has been cancelled."

      # send_message('+65' + walkin.phone, message)
    end
  end

end
