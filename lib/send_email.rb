module SendEmail
  def send_email(recipient_name, recipient_email, subject, body)
    RestClient.post "https://api:key-ec2fc031fc883e704f9b5ce508a744cb"\
        "@api.mailgun.net/v3/sandbox06394e9798594309bae2a8704d3ba128.mailgun.org/messages",
        :from => "Locavorus Rex <postmaster@sandbox06394e9798594309bae2a8704d3ba128.mailgun.org>",
        :to => recipient_name + " <" + recipient_email + ">",
        :subject => subject,
        :text => body
  end
end
