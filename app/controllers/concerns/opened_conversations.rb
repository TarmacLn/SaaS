# Keeps track of the conversation windows a user has open, in the session,
# so they stay open across pages until the user closes them.
module OpenedConversations
  extend ActiveSupport::Concern

  private

  def opened_conversation_ids
    session[:private_conversations] ||= []
  end

  def add_to_conversations(conversation)
    opened_conversation_ids << conversation.id unless already_added?(conversation)
  end

  def already_added?(conversation)
    opened_conversation_ids.include?(conversation.id)
  end

  def remove_from_conversations(conversation)
    opened_conversation_ids.delete(conversation.id)
  end
end
