# Preview all emails at http://localhost:3000/rails/mailers/gmailer_mailer
class GmailerMailerPreview < ActionMailer::Preview
  def send_reservation_confirmation_preview
    GmailerMailer.send_reservation_confirmation(Reservation.first, 'Reservation confirmed!!!')
  end
end
