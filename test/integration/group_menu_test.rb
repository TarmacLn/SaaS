require "test_helper"

class GroupMenuTest < ActionDispatch::IntegrationTest
  setup do
    @group = group_conversations(:study_group)
  end

  test "groups show in the conversations menu with their unread state" do
    sign_in users(:three) # hasn't read anything in the group
    get root_path

    assert_select "#conversations-menu-items form[action=?] .conversation-item.unseen-conv",
                  open_group_conversation_path(@group) do
      assert_select ".conversation-item-name", text: @group.name
      assert_select ".group-avatar"
    end
    assert_select "#conversations-menu a[href=?]", new_group_conversation_path
  end

  test "messenger lists and opens a group" do
    sign_in users(:three)
    get messenger_group_path(@group)

    assert_response :success
    assert_select "#messenger-conversations a.conversation-item[data-conversation-key=?]", "gc#{@group.id}"
    assert_select ".messenger[data-messenger-selected-value=?]", "gc#{@group.id}"
    assert_select ".messenger-conversation .contact-name-notif", text: /#{@group.name}/
    assert_select ".messenger-conversation .group-members-count", text: "3 members"
    assert_select ".messenger-conversation li.message-received.unseen", minimum: 1
  end

  test "messenger cannot open a group the user isn't in" do
    sign_in User.create!(name: "Outsider", email: "outsider@example.com", password: "password")
    get messenger_group_path(@group)
    assert_response :not_found
  end
end
