require 'test_helper'

class WalkinControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get walkin_login_url
    assert_response :success
  end

  test "should get logout" do
    get walkin_logout_url
    assert_response :success
  end

end
