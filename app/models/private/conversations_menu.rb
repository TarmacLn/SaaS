# A user's conversations (private and group) for the navbar menu and the messenger,
# newest activity first, with the latest message of each and which ones have unread messages.
class Private::ConversationsMenu
  NAVBAR_LIMIT = 10

  attr_reader :user

  def initialize(user, limit: nil)
    @user = user
    @limit = limit
  end

  def conversations
    @conversations ||= begin
      all = (private_scope.to_a + group_scope.to_a).sort_by(&:updated_at).reverse
      @limit ? all.first(@limit) : all
    end
  end

  def unseen?(conversation)
    unseen_ids_for(conversation.class).include?(conversation.id)
  end

  # conversations with messages the user hasn't seen
  def unseen_count
    unseen_ids_for(Private::Conversation).size + unseen_ids_for(Group::Conversation).size
  end

  def last_message(conversation)
    last_messages_for(conversation.class)[conversation.id]
  end

  private

  def private_scope
    scope = Private::Conversation.for_user(user).includes(:sender, :recipient).order(updated_at: :desc)
    @limit ? scope.limit(@limit) : scope
  end

  def group_scope
    scope = Group::Conversation.for_user(user).order(updated_at: :desc)
    @limit ? scope.limit(@limit) : scope
  end

  def unseen_ids_for(conversation_class)
    @unseen_ids ||= {}
    @unseen_ids[conversation_class] ||=
      if conversation_class == Group::Conversation
        # other members' messages after the last one this user read
        Group::Message.joins("JOIN group_memberships ON group_memberships.conversation_id = group_messages.conversation_id")
                      .where(group_memberships: { user_id: user.id })
                      .where("group_memberships.last_read_message_id IS NULL OR group_messages.id > group_memberships.last_read_message_id")
                      .where.not(user_id: user.id)
                      .distinct.pluck(:conversation_id).to_set
      else
        Private::Message.unseen_by(user)
                        .where(conversation_id: Private::Conversation.for_user(user))
                        .distinct.pluck(:conversation_id).to_set
      end
  end

  def last_messages_for(conversation_class)
    @last_messages ||= {}
    @last_messages[conversation_class] ||= begin
      message_class = conversation_class == Group::Conversation ? Group::Message : Private::Message
      ids = conversations.select { |conversation| conversation.is_a?(conversation_class) }.map(&:id)
      message_class.where(conversation_id: ids)
                   .includes(:user)
                   .select("DISTINCT ON (conversation_id) *")
                   .order(:conversation_id, id: :desc)
                   .index_by(&:conversation_id)
    end
  end
end
