require "test_helper"

class Private::MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @conversation = private_conversations(:one_and_two)
  end

  test "guest cannot send a message" do
    post private_messages_path, params: { conversation_id: @conversation.id, body: "Hi" }
    assert_redirected_to new_user_session_path
  end

  test "sends a message and adds it to the window" do
    sign_in users(:two)

    assert_difference "@conversation.messages.count", 1 do
      post private_messages_path, params: { conversation_id: @conversation.id, body: "See you there!" },
                                  as: :turbo_stream
    end

    message = @conversation.messages.order(:id).last
    assert_equal users(:two), message.user
    assert_match %(<turbo-stream action="append" target="pc#{@conversation.id}-messages">), response.body
    assert_match "See you there!", response.body
    assert_match %(<turbo-stream action="replace" target="pc#{@conversation.id}-form">), response.body
    assert_match %(datetime="#{message.created_at.utc.iso8601}"), response.body
    assert_match %(data-controller="local-time"), response.body
  end

  test "an empty message is not sent" do
    sign_in users(:two)

    assert_no_difference "Private::Message.count" do
      post private_messages_path, params: { conversation_id: @conversation.id, body: " " }, as: :turbo_stream
    end
    assert_response :unprocessable_entity
  end

  test "cannot send a message to someone else's conversation" do
    sign_in User.create!(name: "Nosy", email: "nosy@example.com", password: "password")

    assert_no_difference "Private::Message.count" do
      post private_messages_path, params: { conversation_id: @conversation.id, body: "Hi" }, as: :turbo_stream
    end
    assert_response :not_found
  end

  def add_messages(count)
    Array.new(count) { |i| @conversation.messages.create!(user: users(:one), body: "Message #{i}") }
  end

  def load_older(before: nil)
    get private_messages_path(conversation_id: @conversation.id, before: before), as: :turbo_stream
  end

  test "guest cannot load messages" do
    get private_messages_path(conversation_id: @conversation.id)
    assert_redirected_to new_user_session_path
  end

  test "cannot load someone else's messages" do
    sign_in User.create!(name: "Nosy", email: "nosy@example.com", password: "password")
    load_older
    assert_response :not_found
  end

  test "loads the batch of messages before the given one, oldest first" do
    per_page = Private::ConversationsHelper::MESSAGES_PER_PAGE
    added = add_messages(per_page + 5)
    sign_in users(:two)

    load_older(before: added.last.id)

    assert_response :success
    shown = response.body.scan(/Message (\d+)/).flatten.map(&:to_i)
    assert_equal (4...(per_page + 4)).to_a, shown, "the #{per_page} messages right before the last one"
    assert_match %(<turbo-stream action="remove" target="pc#{@conversation.id}-load-more">), response.body
    assert_match %(<turbo-stream action="prepend" target="pc#{@conversation.id}-messages">), response.body
    assert_match %(id="pc#{@conversation.id}-load-more"), response.body, "more are left, so a new loader"
  end

  test "the oldest batch has no loader after it" do
    added = add_messages(3)
    sign_in users(:two)

    load_older(before: added.first.id)

    assert_match "tennis", response.body
    assert_match "Saturday", response.body
    assert_no_match %(id="pc#{@conversation.id}-load-more"), response.body
  end
end
