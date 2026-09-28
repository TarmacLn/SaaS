class Group::Message < ApplicationRecord
  self.table_name = "group_messages"

  belongs_to :user
  belongs_to :conversation,
             class_name: "Group::Conversation",
             inverse_of: :messages,
             touch: true # keeps conversations ordered by their latest message

  validates :body, presence: true, length: { maximum: 1000 }

  after_create_commit :broadcast_to_members

  private

  # Real-time delivery to every member over their own stream
  def broadcast_to_members
    conversation.users.each do |member|
      broadcast_append_to member, :private_conversations,
                          target: "gc#{conversation_id}-messages",
                          partial: "group/messages/message",
                          locals: { message: self, unseen: member.id != user_id }

      unless member.id == user_id
        # opens the group's window if the member doesn't have it open
        broadcast_append_to member, :private_conversations,
                            target: "incoming-messages",
                            partial: "private/messages/incoming",
                            locals: { group_conversation_id: conversation_id }
      end

      conversation.broadcast_menu_to(member)
    end
  end
end
