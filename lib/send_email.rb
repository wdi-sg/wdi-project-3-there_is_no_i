module SendEmail
  def send_email(recipient_name, recipient_email, subject, body)
    RestClient.post "https://api:#{ENV['MAILGUN_API_KEY']}"\
        "@api.mailgun.net/v3/sandbox06394e9798594309bae2a8704d3ba128.mailgun.org/messages",
        :from => "Locavorus Rex <postmaster@sandbox06394e9798594309bae2a8704d3ba128.mailgun.org>",
        :to => recipient_name + " <" + recipient_email + ">",
        :subject => subject,
        :text => body
  end
end
