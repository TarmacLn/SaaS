require "test_helper"
require "turbo/broadcastable/test_helper"

class Private::MessageBroadcastTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  setup do
    @conversation = private_conversations(:one_and_two) # sender: one, recipient: two
  end

  def send_message(from:)
    @conversation.messages.create!(user: from, body: "Real-time hello")
  end

  test "a new message is appended to the window on both users' streams" do
    streams = [ users(:one), users(:two) ].index_with do |user|
      capture_turbo_stream_broadcasts([ user, :private_conversations ]) { send_message(from: users(:one)) }
    end

    streams.each do |user, broadcasts|
      append = broadcasts.find { |stream| stream["target"] == "pc#{@conversation.id}-messages" }
      assert append, "#{user.name} gets the message"
      assert_equal "append", append["action"]
      assert_match "Real-time hello", append.to_html
      assert_match %(data-user-id="#{users(:one).id}"), append.to_html
    end
  end

  test "only the recipient gets the notice that opens the window" do
    recipient = capture_turbo_stream_broadcasts([ users(:two), :private_conversations ]) { send_message(from: users(:one)) }
    sender = capture_turbo_stream_broadcasts([ users(:one), :private_conversations ]) { send_message(from: users(:one)) }

    notice = recipient.find { |stream| stream["target"] == "incoming-messages" }
    assert notice
    assert_match %(data-incoming-message-window-id-value="pc#{@conversation.id}"), notice.to_html
    assert_match "expanded=false", notice.to_html
    assert_nil sender.find { |stream| stream["target"] == "incoming-messages" }
  end

  test "the first message of a new conversation is broadcast too" do
    visitor = User.create!(name: "Visitor", email: "visitor@example.com", password: "password")

    broadcasts = capture_turbo_stream_broadcasts([ users(:one), :private_conversations ]) do
      conversation = Private::Conversation.new(sender: visitor, recipient: users(:one))
      conversation.messages.build(user: visitor, body: "Hi from a new conversation")
      conversation.save!
    end

    assert(broadcasts.any? { |stream| stream["target"] == "incoming-messages" })
  end

  test "a message that fails to save is not broadcast" do
    assert_no_turbo_stream_broadcasts [ users(:two), :private_conversations ] do
      @conversation.messages.create(user: users(:one), body: "")
    end
  end
end
