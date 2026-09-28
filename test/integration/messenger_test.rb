require "test_helper"

class MessengerTest < ActionDispatch::IntegrationTest
  setup do
    @conversation = private_conversations(:one_and_two)
    # these tests are about private conversations: the fixture group is already read
    Group::Membership.update_all(last_read_message_id: Group::Message.maximum(:id))
  end

  test "navbar shows the conversations menu with the unread badge" do
    sign_in users(:one) # has an unseen reply from users(:two)
    get root_path

    assert_select "#conversations-menu" do
      assert_select "#unseen-conversations:not([hidden])", text: /1/
      assert_select "#conversations-menu-items form[action=?] .conversation-item.unseen-conv",
                    open_private_conversation_path(@conversation) do
        assert_select ".conversation-item-name", text: users(:two).name
      end
      assert_select "a[href=?]", messenger_path
    end
  end

  test "the badge is hidden without unread conversations" do
    sign_in users(:two)
    get root_path

    assert_select "#unseen-conversations[hidden]"
  end

  test "guests have no conversations menu" do
    get root_path
    assert_select "#conversations-menu", count: 0
  end

  test "mark_as_seen marks the other person's messages as seen" do
    sign_in users(:one)

    post mark_as_seen_private_conversation_path(@conversation)

    assert_response :no_content
    assert private_messages(:reply).reload.seen
    get root_path
    assert_select "#unseen-conversations[hidden]"
  end

  test "cannot mark someone else's conversation as seen" do
    sign_in User.create!(name: "Nosy", email: "nosy@example.com", password: "password")

    post mark_as_seen_private_conversation_path(@conversation)
    assert_response :not_found
    assert_not private_messages(:reply).reload.seen
  end

  test "guest is sent to log in for the messenger" do
    get messenger_path
    assert_redirected_to new_user_session_path
  end

  test "messenger lists conversations and opens the most recent one" do
    sign_in users(:one)
    get messenger_path

    assert_response :success
    assert_select "#messenger-conversations a.conversation-item.selected[href=?]",
                  messenger_path(conversation_id: @conversation.id)
    assert_select ".messenger-conversation[data-conversation-window-mark-seen-url-value=?]",
                  mark_as_seen_private_conversation_path(@conversation) do
      assert_select "#pc#{@conversation.id}-messages li", text: /Saturday/
      assert_select "form#pc#{@conversation.id}-form"
    end
    assert_select "#conversations-windows", count: 0, text: nil
  end

  test "messenger opens a chosen conversation" do
    sign_in users(:two)
    get messenger_path(conversation_id: @conversation.id)

    assert_select ".messenger-conversation .contact-name-notif", text: users(:one).name
  end

  test "messenger cannot open someone else's conversation" do
    sign_in User.create!(name: "Nosy", email: "nosy@example.com", password: "password")
    get messenger_path(conversation_id: @conversation.id)
    assert_response :not_found
  end

  test "messenger without conversations shows a hint" do
    sign_in User.create!(name: "New", email: "new@example.com", password: "password")
    get messenger_path

    assert_select ".conversations-empty"
    assert_select ".messenger-placeholder"
  end

  test "windows carry the mark as seen url" do
    sign_in users(:one)
    post open_private_conversation_path(@conversation), as: :turbo_stream

    get root_path
    assert_select "#pc#{@conversation.id}[data-conversation-window-mark-seen-url-value=?]",
                  mark_as_seen_private_conversation_path(@conversation)
  end
end
