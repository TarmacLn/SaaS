require "test_helper"

class Group::MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = group_conversations(:study_group)
  end

  test "a member sends a message" do
    sign_in users(:three)

    assert_difference "@group.messages.count", 1 do
      post group_messages_path, params: { conversation_id: @group.id, body: "I can on Friday" }, as: :turbo_stream
    end
    assert_equal users(:three), @group.messages.order(:id).last.user
    assert_match %(<turbo-stream action="append" target="gc#{@group.id}-messages">), response.body
  end

  test "non-members cannot send or read messages" do
    sign_in User.create!(name: "Outsider", email: "outsider@example.com", password: "password")

    assert_no_difference "Group::Message.count" do
      post group_messages_path, params: { conversation_id: @group.id, body: "Hi" }, as: :turbo_stream
    end
    assert_response :not_found
  end

  test "an empty message is not sent" do
    sign_in users(:three)

    assert_no_difference "Group::Message.count" do
      post group_messages_path, params: { conversation_id: @group.id, body: "" }, as: :turbo_stream
    end
    assert_response :unprocessable_entity
  end

  test "loads older messages" do
    newest = 25.times.map { |i| @group.messages.create!(user: users(:one), body: "Group message #{i}") }.last
    sign_in users(:two)

    get group_messages_path(conversation_id: @group.id, before: newest.id), as: :turbo_stream

    assert_response :success
    assert_match %(<turbo-stream action="prepend" target="gc#{@group.id}-messages">), response.body
    assert_match "Group message 23", response.body
    assert_no_match "Group message 24", response.body
  end
end
