require "test_helper"

class Group::MembershipTest < ActiveSupport::TestCase
  test "a user can only be in a group once" do
    duplicate = Group::Membership.new(conversation: group_conversations(:study_group), user: users(:one))
    assert_not duplicate.valid?
  end
end
