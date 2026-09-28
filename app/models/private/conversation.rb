class Private::Conversation < ApplicationRecord
  self.table_name = "private_conversations"

  has_many :messages,
           class_name: "Private::Message",
           foreign_key: :conversation_id,
           inverse_of: :conversation,
           dependent: :destroy
  belongs_to :sender, foreign_key: :sender_id, class_name: "User"
  belongs_to :recipient, foreign_key: :recipient_id, class_name: "User"

  validate :not_with_yourself
  validate :unique_pair_of_users

  scope :between_users, ->(user1_id, user2_id) do
    where(sender_id: user1_id, recipient_id: user2_id).or(
      where(sender_id: user2_id, recipient_id: user1_id)
    )
  end

  scope :for_user, ->(user) { where(sender: user).or(where(recipient: user)) }

  # get the other user of the conversation
  def opposed_user(user)
    user == recipient ? sender : recipient
  end

  private

  def not_with_yourself
    errors.add(:recipient, "can't be yourself") if sender_id.present? && sender_id == recipient_id
  end

  # The unique index only covers sender -> recipient; also block recipient -> sender
  def unique_pair_of_users
    if Private::Conversation.between_users(sender_id, recipient_id).where.not(id: id).exists?
      errors.add(:base, "A conversation between these users already exists")
    end
  end
end
