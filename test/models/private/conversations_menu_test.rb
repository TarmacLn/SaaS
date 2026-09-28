require "test_helper"

class Private::ConversationsMenuTest < ActiveSupport::TestCase
  setup do
    @conversation = private_conversations(:one_and_two)
    @third = User.create!(name: "Third", email: "third@example.com", password: "password")
  end

  test "lists the user's conversations, most recent activity first" do
    newer = Private::Conversation.new(sender: @third, recipient: users(:one))
    newer.messages.build(user: @third, body: "Newer conversation")
    newer.save!

    assert_equal [ newer, @conversation ], Private::ConversationsMenu.new(users(:one)).conversations
    assert_equal [ @conversation ], Private::ConversationsMenu.new(users(:two)).conversations

    @conversation.messages.create!(user: users(:two), body: "Bump")
    assert_equal [ @conversation, newer ], Private::ConversationsMenu.new(users(:one)).conversations
  end

  test "the navbar limit" do
    assert_equal 1, Private::ConversationsMenu.new(users(:one), limit: 1).conversations.size
  end

  test "knows which conversations have unseen messages from the other person" do
    # fixtures: users(:two)'s reply is unseen by users(:one); users(:one)'s message was seen
    assert Private::ConversationsMenu.new(users(:one)).unseen?(@conversation)
    assert_equal 1, Private::ConversationsMenu.new(users(:one)).unseen_count
    assert_not Private::ConversationsMenu.new(users(:two)).unseen?(@conversation)
    assert_equal 0, Private::ConversationsMenu.new(users(:two)).unseen_count
  end

  test "last_message is the newest message of each conversation" do
    latest = @conversation.messages.create!(user: users(:one), body: "Latest one")
    assert_equal latest, Private::ConversationsMenu.new(users(:two)).last_message(@conversation)
  end
end
