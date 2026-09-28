require "test_helper"

class ConversationWindowsTest < ActionDispatch::IntegrationTest
  setup do
    @conversation = private_conversations(:one_and_two)
    @window = "#pc#{@conversation.id}"
  end

  test "guests have no conversation windows and no real-time stream" do
    get root_path
    assert_select "#conversations-windows", count: 0
    assert_select "turbo-cable-stream-source", count: 0
    assert_select "meta[name=current-user-id][content='']"
  end

  test "no windows are open until a conversation is opened" do
    sign_in users(:one)
    get root_path

    assert_select "#conversations-windows .conversation-window", count: 0
  end

  test "signed-in users subscribe to their own real-time stream" do
    sign_in users(:one)
    get root_path

    stream = Turbo::StreamsChannel.signed_stream_name([ users(:one), :private_conversations ])
    assert_select "turbo-cable-stream-source[signed-stream-name=?]", stream
    assert_select "#incoming-messages[hidden]"
    assert_select "meta[name=current-user-id][content=?]", users(:one).id.to_s
    assert_select "meta[name=action-cable-url]"
  end

  test "an incoming message can open its window collapsed" do
    sign_in users(:two)
    post open_private_conversation_path(@conversation, expanded: false), as: :turbo_stream

    assert_match %(data-conversation-window-expanded-value="false"), response.body
  end

  test "sending the first message on a post opens its window on every page" do
    visitor = User.create!(name: "Visitor", email: "visitor@example.com", password: "password")
    sign_in visitor

    post private_conversations_path, params: { post_id: posts(:hobby_post).id, message_body: "Hello there!" },
                                     as: :turbo_stream
    conversation = Private::Conversation.last
    assert_match %(<turbo-stream action="prepend" target="conversations-windows">), response.body

    get hobby_posts_path
    assert_select "#pc#{conversation.id}.conversation-window[data-turbo-permanent]" do
      assert_select ".contact-name-notif", text: users(:one).name
      assert_select ".message-sent", text: /Hello there!/
    end
  end

  test "opening and closing a conversation window" do
    sign_in users(:one)

    post open_private_conversation_path(@conversation), as: :turbo_stream
    assert_match %(<turbo-stream action="prepend" target="conversations-windows">), response.body
    get root_path
    assert_select @window do
      assert_select "ul[data-controller=message-dates]"
      assert_select ".contact-name-notif", text: users(:two).name
      assert_select ".message-sent", text: /tennis/
      assert_select ".message-received.unseen", text: /Saturday/
    end

    post close_private_conversation_path(@conversation), as: :turbo_stream
    assert_match %(<turbo-stream action="remove" target="pc#{@conversation.id}">), response.body
    get root_path
    assert_select @window, count: 0
  end

  test "cannot open someone else's conversation" do
    sign_in User.create!(name: "Nosy", email: "nosy@example.com", password: "password")

    post open_private_conversation_path(@conversation), as: :turbo_stream
    assert_response :not_found
  end

  test "an open window from a previous user is not shown to the next one" do
    sign_in users(:one)
    post open_private_conversation_path(@conversation), as: :turbo_stream
    sign_out :user

    sign_in User.create!(name: "Next", email: "next@example.com", password: "password")
    get root_path
    assert_select @window, count: 0
  end

  test "the post page offers to open an existing conversation" do
    sign_in users(:two)
    get post_path(posts(:hobby_post))

    assert_select ".contacted-user form[action=?]", open_private_conversation_path(@conversation)
  end

  test "a long conversation shows its latest messages with a loader for older ones" do
    per_page = Private::ConversationsHelper::MESSAGES_PER_PAGE
    (per_page + 3).times { |i| @conversation.messages.create!(user: users(:one), body: "Message #{i}") }
    sign_in users(:one)
    post open_private_conversation_path(@conversation), as: :turbo_stream

    get root_path
    assert_select "#{@window} ul > li[id^=private_message_]", count: per_page
    assert_select "#{@window} ul > li:first-child.load-more-messages[data-controller=older-messages]"
    assert_select "#{@window} li", text: /Message #{per_page + 2}/
  end

  test "a short conversation has no loader" do
    sign_in users(:one)
    post open_private_conversation_path(@conversation), as: :turbo_stream

    get root_path
    assert_select "#{@window} .load-more-messages", count: 0
  end
end
