require "test_helper"
require "turbo/broadcastable/test_helper"

class Group::MessageTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  def group
    group_conversations(:study_group)
  end

  test "belongs to a user and a group" do
    assert_equal users(:one), group_messages(:welcome).user
    assert_equal group, group_messages(:welcome).conversation
  end

  test "requires a body of at most 1000 characters" do
    assert Group::Message.new.tap(&:valid?).errors.added?(:body, :blank)
    assert_not Group::Message.new(body: "a" * 1001).tap(&:valid?).errors[:body].empty?
  end

  test "a new message moves the group to the top" do
    group.update_column(:updated_at, 1.day.ago)
    group.messages.create!(user: users(:one), body: "Bump")
    assert_in_delta Time.current, group.reload.updated_at, 5.seconds
  end

  test "is broadcast to every member, with a notice for everyone but the author" do
    [ users(:one), users(:two), users(:three) ].each do |member|
      broadcasts = capture_turbo_stream_broadcasts([ member, :private_conversations ]) do
        group.messages.create!(user: users(:one), body: "Hello group")
      end
      targets = broadcasts.map { |stream| stream["target"] }

      assert_includes targets, "gc#{group.id}-messages"
      assert_includes targets, "conversations-menu-items"
      assert_equal member != users(:one), targets.include?("incoming-messages")
    end
  end

  test "outsiders get nothing" do
    outsider = User.create!(name: "Outsider", email: "outsider@example.com", password: "password")
    assert_no_turbo_stream_broadcasts [ outsider, :private_conversations ] do
      group.messages.create!(user: users(:one), body: "Members only")
    end
  end

  test "deleting a user deletes their group messages and memberships" do
    assert_difference({ "Group::Message.count" => -1, "Group::Membership.count" => -1 }) do
      users(:two).destroy
    end
  end
end
