require "test_helper"

class Private::ConversationTest < ActiveSupport::TestCase
  def conversation
    private_conversations(:one_and_two)
  end

  test "has a sender and a recipient" do
    assert_equal users(:one), conversation.sender
    assert_equal users(:two), conversation.recipient
  end

  test "has many messages" do
    assert_equal [ private_messages(:hello), private_messages(:reply) ].sort, conversation.messages.sort
  end

  test "requires a sender and a recipient" do
    new_conversation = Private::Conversation.new
    assert_not new_conversation.valid?
    assert new_conversation.errors.added?(:sender, :blank)
    assert new_conversation.errors.added?(:recipient, :blank)
  end

  test "cannot start a conversation with yourself" do
    new_conversation = Private::Conversation.new(sender: users(:one), recipient: users(:one))
    assert_not new_conversation.valid?
    assert_includes new_conversation.errors[:recipient], "can't be yourself"
  end

  test "cannot duplicate a conversation in either direction" do
    assert_not Private::Conversation.new(sender: users(:one), recipient: users(:two)).valid?
    assert_not Private::Conversation.new(sender: users(:two), recipient: users(:one)).valid?
  end

  test "an existing conversation is still valid" do
    assert conversation.valid?
  end

  test "deleting a conversation deletes its messages" do
    assert_difference "Private::Message.count", -2 do
      conversation.destroy
    end
  end
end
