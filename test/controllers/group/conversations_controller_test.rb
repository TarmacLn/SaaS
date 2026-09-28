require "test_helper"

class Group::ConversationsControllerTest < ActionDispatch::IntegrationTest
  # fixtures: one & two are contacts; three asked one (pending); one, two, three are in the study group

  setup do
    @group = group_conversations(:study_group)
  end

  def create_group(name: "Weekend project", user_ids: [ users(:two).id ])
    post group_conversations_path, params: { group_conversation: { name: name, user_ids: user_ids } }
  end

  test "guest cannot create a group" do
    get new_group_conversation_path
    assert_redirected_to new_user_session_path
  end

  test "the new group form lists the user's contacts" do
    sign_in users(:one)
    get new_group_conversation_path

    assert_response :success
    assert_select "input[type=checkbox][name='group_conversation[user_ids][]'][value=?]", users(:two).id.to_s
    assert_select "input[type=checkbox][value=?]", users(:three).id.to_s, count: 0 # pending, not a contact
  end

  test "creates a group with the user and the chosen contacts" do
    sign_in users(:one)

    assert_difference({ "Group::Conversation.count" => 1, "Group::Membership.count" => 2 }) do
      create_group
    end

    group = Group::Conversation.order(:id).last
    assert_equal "Weekend project", group.name
    assert_equal [ users(:one), users(:two) ].sort, group.users.sort
    assert_redirected_to messenger_group_path(group)
  end

  test "only contacts can be added" do
    sign_in users(:one)

    assert_no_difference "Group::Conversation.count" do
      create_group(user_ids: [ users(:three).id ]) # not a contact yet
    end
    assert_response :unprocessable_entity
    assert_select ".alert", text: /at least two members/
  end

  test "a group needs a name" do
    sign_in users(:one)

    assert_no_difference "Group::Conversation.count" do
      create_group(name: "")
    end
    assert_response :unprocessable_entity
  end

  test "a member adds contacts to the group" do
    group = Group::Conversation.new(name: "Pair").tap do |g|
      g.memberships.build(user: users(:one))
      g.memberships.build(user: users(:two))
      g.save!
    end
    contacts(:three_asks_one).accept!
    sign_in users(:one)

    get edit_group_conversation_path(group)
    assert_select "input[type=checkbox][value=?]", users(:three).id.to_s
    assert_select "input[type=checkbox][value=?]", users(:two).id.to_s, count: 0 # already in

    patch group_conversation_path(group), params: { group_conversation: { user_ids: [ users(:three).id ] } }
    assert_redirected_to messenger_group_path(group)
    assert group.reload.member?(users(:three))
  end

  test "adding nobody shows an error" do
    sign_in users(:one)
    patch group_conversation_path(@group), params: { group_conversation: { user_ids: [] } }

    assert_response :unprocessable_entity
  end

  test "non-members cannot see, open or change a group" do
    outsider = User.create!(name: "Outsider", email: "outsider@example.com", password: "password")
    sign_in outsider

    get edit_group_conversation_path(@group)
    assert_response :not_found
  end

  test "non-members cannot open a group window" do
    sign_in User.create!(name: "Outsider", email: "outsider@example.com", password: "password")
    post open_group_conversation_path(@group), as: :turbo_stream
    assert_response :not_found
  end

  test "opening, showing and closing a group window" do
    sign_in users(:two)

    post open_group_conversation_path(@group), as: :turbo_stream
    assert_match %(<turbo-stream action="prepend" target="conversations-windows">), response.body

    get root_path
    assert_select "#gc#{@group.id}.conversation-window" do
      assert_select ".contact-name-notif", text: @group.name
      assert_select "a.add-people-to-chat[href=?]", edit_group_conversation_path(@group)
      assert_select "li .message-author", text: users(:one).name
      assert_select "form#gc#{@group.id}-form[action=?]", group_messages_path
    end

    post close_group_conversation_path(@group), as: :turbo_stream
    get root_path
    assert_select "#gc#{@group.id}", count: 0
  end

  test "mark_as_seen marks the group as read for the user" do
    sign_in users(:three)

    post mark_as_seen_group_conversation_path(@group)
    assert_response :no_content
    assert_empty @group.unseen_messages_for(users(:three))
  end
end
