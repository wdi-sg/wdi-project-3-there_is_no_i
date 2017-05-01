class TestReserveMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.test_reserve_mailer.test_confirm_email.subject
  #
  default from: "me@sandbox59fcccabb3de4bffa08b1c3c7286ce77.com"

  # EXAMPLE:
  # def test_confirm_email
  #   @greeting = "Hi"
  #   mail to: "to@example.org"
  # end

  def test_reserve_mailer(reservation)
    @reservation = reservation
    mail to: "recipient@MYDOMAIN.com", subject: "Your reservation has been confirmed!"
  end
end
