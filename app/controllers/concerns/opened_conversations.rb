# Keeps track of the conversation windows a user has open, in the session,
# so they stay open across pages until the user closes them.
# Private and group windows are kept apart, like the tutorial's
# session[:private_conversations] and session[:group_conversations].
module OpenedConversations
  extend ActiveSupport::Concern

  private

  def opened_conversation_ids(conversation_class = Private::Conversation)
    session[session_key_for(conversation_class)] ||= []
  end

  def add_to_conversations(conversation)
    ids = opened_conversation_ids(conversation.class)
    ids << conversation.id unless ids.include?(conversation.id)
  end

  def already_added?(conversation)
    opened_conversation_ids(conversation.class).include?(conversation.id)
  end

  def remove_from_conversations(conversation)
    opened_conversation_ids(conversation.class).delete(conversation.id)
  end

  def session_key_for(conversation_class)
    conversation_class == Group::Conversation ? :group_conversations : :private_conversations
  end
end
