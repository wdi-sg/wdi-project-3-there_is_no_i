module SendTwilio
  require 'rubygems'
  require 'twilio-ruby'

  def send_message(number, message)
    twilio_account_sid = "ACc748f6414b6a04cfae120f1e9f3e2b9b"
    # twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
    twilio_auth_token = "ba7f421bdc29b2ca609f3b6e047b3b94"
    # twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']
    client = Twilio::REST::Client.new account_sid, auth_token
    from = "+61428086370" # Your Twilio number
    client.account.messages.create(
      :from => from,
      :to => number,
      :body => message
    )
  end
end
