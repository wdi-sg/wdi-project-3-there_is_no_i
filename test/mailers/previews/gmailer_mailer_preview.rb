# Preview all emails at http://localhost:3000/rails/mailers/gmailer_mailer
class GmailerMailerPreview < ActionMailer::Preview
  def send_reservation_confirmation_preview
    GmailerMailer.send_reservation_confirmation(Reservation.first, Reservation.first.email, 'Reservation confirmed!!!')
  end

  def send_reservation_update_preview
    GmailerMailer.send_reservation_update(Reservation.last, Reservation.first.email, 'Reservation confirmed!!!')
  end

  def send_takeaway_confirmation_preview
    GmailerMailer.send_takeaway_confirmation(Invoice.last, Invoice.last.user.email, 'Takeaway confirmed!!!')
  end
end
