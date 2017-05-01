# Preview all emails at http://localhost:3000/rails/mailers/test_reserve_mailer
class TestReserveMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/test_reserve_mailer/test_confirm_email
  def test_confirm_email
    TestReserveMailer.test_confirm_email
  end

end
