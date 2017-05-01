require 'test_helper'

class TestReserveMailerTest < ActionMailer::TestCase
  test "test_confirm_email" do
    mail = TestReserveMailer.test_confirm_email
    assert_equal "Test confirm email", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
