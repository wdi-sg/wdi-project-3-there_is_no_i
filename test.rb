require 'rest-client'

def send_simple_message
  RestClient.post "https://api:key-ec2fc031fc883e704f9b5ce508a744cb"\
      "@api.mailgun.net/v3/sandbox06394e9798594309bae2a8704d3ba128.mailgun.org/messages",
      :from => "Mailgun Sandbox <postmaster@sandbox06394e9798594309bae2a8704d3ba128.mailgun.org>",
      :to => "Jonathan <jonathanlouisng@gmail.com>",
      :subject => "Hello Jonathan",
      :text => "Congratulations Jonathan, you just sent an email with Mailgun!  You are truly awesome!"
end

send_simple_message
