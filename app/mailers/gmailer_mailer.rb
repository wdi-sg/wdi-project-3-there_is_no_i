class GmailerMailer < ApplicationMailer
  default from: 'Locavorus <locavorus@gmail.com>'
  include Format

  def send_reservation_confirmation(reservation, email, subject)
    @reservation = reservation
    @email = email
    @subject = subject
    mail(from: 'Locavorus <locavorus@gmail.com>', to: @email, subject: @subject)
  end

  def send_reservation_update(reservation, email, subject)
    @reservation = reservation
    @email = email
    @subject = subject
    mail(from: 'Locavorus <locavorus@gmail.com>', to: @email, subject: @subject)
  end

  def send_takeaway_confirmation(invoice, email, subject)
    @invoice = invoice
    @email = email
    @subject = subject
    mail(from: 'Locavorus <locavorus@gmail.com>', to: @email, subject: @subject)
  end
end
