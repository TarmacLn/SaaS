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
end
