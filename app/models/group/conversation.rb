class Group::Conversation < ApplicationRecord
  include ConversationsMenuBroadcasts

  self.table_name = "group_conversations"

  has_many :memberships,
           class_name: "Group::Membership",
           foreign_key: :conversation_id,
           inverse_of: :conversation,
           dependent: :destroy
  has_many :users, through: :memberships
  has_many :messages,
           class_name: "Group::Message",
           foreign_key: :conversation_id,
           inverse_of: :conversation,
           dependent: :destroy

  validates :name, presence: true, length: { maximum: 60 }
  validate :at_least_two_members, on: :create

  scope :for_user, ->(user) { joins(:memberships).where(group_memberships: { user_id: user.id }) }

  def member?(user)
    memberships.exists?(user_id: user.id)
  end

  def membership_for(user)
    memberships.find_by(user_id: user.id)
  end

  # Marks everything up to the latest message as read by the user; returns true if anything changed
  def mark_as_seen_by(user)
    membership = membership_for(user)
    latest_id = messages.maximum(:id)
    return false if membership.nil? || latest_id.nil? || membership.last_read_message_id == latest_id

    membership.update!(last_read_message_id: latest_id)
  end

  # Messages from other members this user hasn't read yet
  def unseen_messages_for(user)
    last_read = membership_for(user)&.last_read_message_id
    scope = messages.where.not(user_id: user.id)
    last_read ? scope.where(id: (last_read + 1)..) : scope
  end

  private

  def at_least_two_members
    errors.add(:base, "A group needs at least two members") if memberships.size < 2
  end
end
