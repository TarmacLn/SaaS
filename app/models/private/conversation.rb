class Private::Conversation < ApplicationRecord
  self.table_name = "private_conversations"

  has_many :messages,
           class_name: "Private::Message",
           foreign_key: :conversation_id,
           dependent: :destroy
  belongs_to :sender, foreign_key: :sender_id, class_name: "User"
  belongs_to :recipient, foreign_key: :recipient_id, class_name: "User"

  validate :not_with_yourself
  validate :unique_pair_of_users

  private

  def not_with_yourself
    errors.add(:recipient, "can't be yourself") if sender_id.present? && sender_id == recipient_id
  end

  # The unique index only covers sender -> recipient; also block recipient -> sender
  def unique_pair_of_users
    duplicate = Private::Conversation
      .where(sender_id: [ sender_id, recipient_id ], recipient_id: [ sender_id, recipient_id ])
      .where.not(id: id)
    errors.add(:base, "A conversation between these users already exists") if duplicate.exists?
  end
end
