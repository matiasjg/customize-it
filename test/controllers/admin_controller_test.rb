require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get logout" do
    get :logout
    assert_response :success
  end

  test "should get stores" do
    get :stores
    assert_response :success
  end

  test "should get edit_store" do
    get :edit_store
    assert_response :success
  end

  test "should get delete_store" do
    get :delete_store
    assert_response :success
  end

end
