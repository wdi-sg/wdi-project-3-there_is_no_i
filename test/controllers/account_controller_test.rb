require 'test_helper'

class AccountControllerTest < ActionDispatch::IntegrationTest
  test "should get password" do
    get account_password_url
    assert_response :success
  end

  test "should get credit_cards" do
    get account_credit_cards_url
    assert_response :success
  end

end
