# A user's conversations for the navbar menu and the messenger, newest activity first,
# with the latest message of each and which ones have unread messages.
class Private::ConversationsMenu
  NAVBAR_LIMIT = 10

  attr_reader :user

  def initialize(user, limit: nil)
    @user = user
    @limit = limit
  end

  def conversations
    @conversations ||= begin
      scope = Private::Conversation.for_user(user).includes(:sender, :recipient).order(updated_at: :desc)
      (@limit ? scope.limit(@limit) : scope).to_a
    end
  end

  # ids of the user's conversations with messages from the other person they haven't seen
  def unseen_conversation_ids
    @unseen_conversation_ids ||= Private::Message.unseen_by(user)
                                                 .where(conversation_id: Private::Conversation.for_user(user))
                                                 .distinct.pluck(:conversation_id).to_set
  end

  def unseen?(conversation)
    unseen_conversation_ids.include?(conversation.id)
  end

  def unseen_count
    unseen_conversation_ids.size
  end

  def last_message(conversation)
    last_messages[conversation.id]
  end

  private

  def last_messages
    @last_messages ||= Private::Message.where(conversation_id: conversations.map(&:id))
                                       .select("DISTINCT ON (conversation_id) *")
                                       .order(:conversation_id, id: :desc)
                                       .index_by(&:conversation_id)
  end
end
