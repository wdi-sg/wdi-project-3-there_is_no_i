require 'test_helper'

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get restaurants_index_url
    assert_response :success
  end

  test "should get show" do
    get restaurants_show_url
    assert_response :success
  end

  test "should get call" do
    get restaurants_call_url
    assert_response :success
  end

  test "should get reserve" do
    get restaurants_reserve_url
    assert_response :success
  end

  test "should get menu" do
    get restaurants_menu_url
    assert_response :success
  end

end
