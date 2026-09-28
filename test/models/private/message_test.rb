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

  test "requires a body of at most 1000 characters" do
    assert Private::Message.new.tap(&:valid?).errors.added?(:body, :blank)
    assert_not Private::Message.new(body: "a" * 1001).tap(&:valid?).errors[:body].empty?
  end

  test "unseen_by finds the other person's unseen messages" do
    assert_equal [ private_messages(:reply) ], Private::Message.unseen_by(users(:one)).to_a
    assert_empty Private::Message.unseen_by(users(:two))
  end
end
