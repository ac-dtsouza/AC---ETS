require 'test_helper'

class RootControllerTest < ActionController::TestCase
  test "should get frequency" do
    get :frequency
    assert_response :success
  end

end
