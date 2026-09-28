class Private::Message < ApplicationRecord
  self.table_name = "private_messages"

  belongs_to :user
  belongs_to :conversation,
             class_name: "Private::Conversation",
             foreign_key: :conversation_id,
             inverse_of: :messages

  validates :body, presence: true, length: { maximum: 1000 }
end
