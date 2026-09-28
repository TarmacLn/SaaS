require "test_helper"

class Private::ConversationsHelperTest < ActionView::TestCase
  def current_user
    users(:one)
  end

  test "private_conv_recipient returns the other user" do
    assert_equal users(:two), private_conv_recipient(private_conversations(:one_and_two))
  end

  test "private_conversation_messages returns the latest messages, oldest first" do
    conversation = private_conversations(:one_and_two)
    conversation.messages.create!(user: users(:one), body: "Newest message")

    messages = private_conversation_messages(conversation)
    assert_equal "Newest message", messages.last.body
    assert_operator messages.size, :<=, Private::ConversationsHelper::MESSAGES_PER_PAGE
  end

  test "load_private_messages adds the loader only when older messages exist" do
    conversation = private_conversations(:one_and_two)
    all = private_conversation_messages(conversation)
    assert_equal "shared/empty_partial", load_private_messages(conversation, all)
    assert_equal "private/messages/load_more_messages", load_private_messages(conversation, all.last(1))
    assert_equal "shared/empty_partial", load_private_messages(conversation, [])
  end
end
