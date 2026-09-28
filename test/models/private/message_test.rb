require "test_helper"

class Private::MessageTest < ActiveSupport::TestCase
  test "belongs to a user and a conversation" do
    message = private_messages(:hello)

    assert_equal users(:one), message.user
    assert_equal private_conversations(:one_and_two), message.conversation
  end

  test "is unseen by default" do
    message = Private::Message.new
    assert_equal false, message.seen
  end

  test "requires a user and a conversation" do
    message = Private::Message.new(body: "Hi")
    assert_not message.valid?
    assert message.errors.added?(:user, :blank)
    assert message.errors.added?(:conversation, :blank)
  end
end
