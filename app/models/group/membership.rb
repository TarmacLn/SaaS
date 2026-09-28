class Group::Membership < ApplicationRecord
  self.table_name = "group_memberships"

  belongs_to :conversation, class_name: "Group::Conversation", inverse_of: :memberships
  belongs_to :user

  validates :user_id, uniqueness: { scope: :conversation_id }
end
