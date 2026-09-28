require "test_helper"

class Private::ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = users(:one)
    @visitor = User.create!(name: "Visitor", email: "visitor@example.com", password: "password")
    @post = posts(:hobby_post) # written by @author
  end

  def send_message(body: "Hi, I'd like to join you for tennis!", as: :turbo_stream)
    post private_conversations_path, params: { post_id: @post.id, message_body: body }, as: as
  end

  test "guest cannot start a conversation" do
    assert_no_difference "Private::Conversation.count" do
      send_message(as: :html)
    end
    assert_redirected_to new_user_session_path
  end

  test "starts a conversation with the post's author and sends the first message" do
    sign_in @visitor

    assert_difference({ "Private::Conversation.count" => 1, "Private::Message.count" => 1 }) do
      send_message
    end

    conversation = Private::Conversation.last
    assert_equal @visitor, conversation.sender
    assert_equal @author, conversation.recipient

    message = conversation.messages.first
    assert_equal @visitor, message.user, "the first message is written by the sender"
    assert_equal "Hi, I'd like to join you for tennis!", message.body
  end

  test "replaces the form with a success message" do
    sign_in @visitor
    send_message

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match %(<turbo-stream action="replace" target="contact-user">), response.body
    assert_match "Message has been sent", response.body
  end

  test "falls back to a redirect without Turbo" do
    sign_in @visitor
    send_message(as: :html)

    assert_redirected_to post_path(@post)
    assert_equal "Message has been sent", flash[:notice]
  end

  test "an empty message creates nothing" do
    sign_in @visitor

    assert_no_difference [ "Private::Conversation.count", "Private::Message.count" ] do
      send_message(body: "")
    end
    assert_response :unprocessable_entity
    assert_match "Message has not been sent", response.body
  end

  test "cannot start a second conversation with the same user" do
    sign_in users(:two) # already talking with users(:one)

    assert_no_difference "Private::Conversation.count" do
      send_message
    end
    assert_response :unprocessable_entity
    assert_match "already exists", response.body
  end

  test "cannot message yourself about your own post" do
    sign_in @author

    assert_no_difference "Private::Conversation.count" do
      send_message
    end
    assert_response :unprocessable_entity
  end
end
