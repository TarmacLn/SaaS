require "test_helper"

class Group::ConversationTest < ActiveSupport::TestCase
  def group
    group_conversations(:study_group)
  end

  test "has members and messages" do
    assert_equal [ users(:one), users(:two), users(:three) ].sort, group.users.sort
    assert_equal [ group_messages(:welcome), group_messages(:question) ].sort, group.messages.sort
  end

  test "requires a name of at most 60 characters" do
    assert_not Group::Conversation.new.tap(&:valid?).errors[:name].empty?
    assert_not Group::Conversation.new(name: "a" * 61).tap(&:valid?).errors[:name].empty?
  end

  test "needs at least two members when created" do
    lonely = Group::Conversation.new(name: "Just me")
    lonely.memberships.build(user: users(:one))
    assert_not lonely.valid?

    lonely.memberships.build(user: users(:two))
    assert lonely.valid?
  end

  test "for_user finds the groups a user is in" do
    assert_equal [ group ], Group::Conversation.for_user(users(:one)).to_a
    outsider = User.create!(name: "Outsider", email: "outsider@example.com", password: "password")
    assert_empty Group::Conversation.for_user(outsider)
  end

  test "member?" do
    assert group.member?(users(:two))
    assert_not group.member?(User.create!(name: "Out", email: "out@example.com", password: "password"))
  end

  test "unseen messages are other members' messages after the last one read" do
    assert_equal [ group_messages(:question) ], group.unseen_messages_for(users(:one)).to_a
    assert_equal [ group_messages(:welcome), group_messages(:question) ].sort,
                 group.unseen_messages_for(users(:three)).sort
  end

  test "mark_as_seen_by marks everything up to the latest message as read" do
    assert group.mark_as_seen_by(users(:three))
    assert_empty group.unseen_messages_for(users(:three))
    assert_not group.mark_as_seen_by(users(:three)), "nothing new to mark"

    newer = group.messages.create!(user: users(:one), body: "New message")
    assert_equal [ newer ], group.unseen_messages_for(users(:three)).to_a
  end

  test "deleting a group deletes its memberships and messages" do
    assert_difference({ "Group::Membership.count" => -3, "Group::Message.count" => -2 }) do
      group.destroy
    end
  end
end
