require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "fixture user is valid" do
    assert users(:one).valid?
  end

  test "requires an email" do
    user = User.new(name: "No Email", password: "password")
    assert_not user.valid?
    assert user.errors.added?(:email, :blank)
  end

  test "requires a unique email regardless of case" do
    user = User.new(name: "Copy", email: users(:one).email.upcase, password: "password")
    assert_not user.valid?
    assert user.errors.added?(:email, :taken, value: users(:one).email)
  end

  test "requires a password of at least 6 characters" do
    user = User.new(name: "Short", email: "short@example.com", password: "12345")
    assert_not user.valid?
    assert user.errors.of_kind?(:password, :too_short)
  end
end
