class Private::Message < ApplicationRecord
  self.table_name = "private_messages"

  belongs_to :user
  belongs_to :conversation,
             class_name: "Private::Conversation",
             foreign_key: :conversation_id,
             inverse_of: :messages,
             touch: true # keeps conversations ordered by their latest message

  validates :body, presence: true, length: { maximum: 1000 }

  # messages from the other person in a conversation that the user hasn't seen yet
  scope :unseen_by, ->(user) { where(seen: false).where.not(user_id: user.id) }

  after_create_commit :broadcast_to_participants

  private

  # Real-time delivery over Action Cable. Each user has their own stream
  # ([user, :private_conversations], subscribed to in the layout).
  def broadcast_to_participants
    # Add the message to the conversation's window, for both users (all their tabs)
    [ conversation.sender, conversation.recipient ].each do |participant|
      broadcast_append_to participant, :private_conversations,
                          target: "pc#{conversation_id}-messages",
                          partial: "private/messages/message",
                          locals: { message: self }
    end

    # If the recipient doesn't have the window open, this makes their browser open it
    broadcast_append_to conversation.opposed_user(user), :private_conversations,
                        target: "incoming-messages",
                        partial: "private/messages/incoming",
                        locals: { message: self }

    # New latest message and unread count in both users' conversations menu
    [ conversation.sender, conversation.recipient ].each { |participant| conversation.broadcast_menu_to(participant) }
  end
end
