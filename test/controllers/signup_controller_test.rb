require 'test_helper'

class SignupControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_new_url
    assert_response :success
  end

end
