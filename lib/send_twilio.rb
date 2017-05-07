module SendTwilio
  # require 'rubygems'
  # require 'twilio-ruby'

  def send_message(recipient, message)
    twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
    twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']
    client = Twilio::REST::Client.new account_sid, auth_token
    client.account.messages.create(
      :from => "+61428086370", # My Twilio number
      :to => recipient,
      :body => message
    )
  end
end
