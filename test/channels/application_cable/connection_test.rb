require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects a signed-in user" do
    connect env: { "warden" => FakeWarden.new(users(:one)) }

    assert_equal users(:one), connection.current_user
  end

  test "rejects guests" do
    assert_reject_connection { connect env: { "warden" => FakeWarden.new(nil) } }
  end

  # Stands in for Devise's Warden proxy
  FakeWarden = Struct.new(:signed_in_user) do
    def user(_scope)
      signed_in_user
    end
  end
end
