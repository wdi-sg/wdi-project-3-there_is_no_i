require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get table" do
    get dashboard_table_url
    assert_response :success
  end

  test "should get schedule" do
    get dashboard_schedule_url
    assert_response :success
  end

  test "should get service" do
    get dashboard_service_url
    assert_response :success
  end

end
