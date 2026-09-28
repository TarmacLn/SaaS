require "test_helper"

class Private::ConversationsHelperTest < ActionView::TestCase
  def current_user
    users(:one)
  end

  test "private_conv_recipient returns the other user" do
    assert_equal users(:two), private_conv_recipient(private_conversations(:one_and_two))
  end

  test "private_message_class tells sent and received messages apart" do
    assert_equal "message-sent", private_message_class(private_messages(:hello))
    assert_equal "message-received", private_message_class(private_messages(:reply))
  end

  test "private_conversation_messages returns the latest messages, oldest first" do
    conversation = private_conversations(:one_and_two)
    conversation.messages.create!(user: users(:one), body: "Newest message")

    messages = private_conversation_messages(conversation)
    assert_equal "Newest message", messages.last.body
    assert_operator messages.size, :<=, Private::ConversationsHelper::MESSAGES_IN_WINDOW
  end
end
