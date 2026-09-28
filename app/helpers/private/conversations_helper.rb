# Helpers for conversation windows and the messenger. Most work for both private
# (Private::Conversation, DOM ids "pc<id>") and group (Group::Conversation, "gc<id>") conversations.
module Private::ConversationsHelper
  # Messages shown when a window opens, and loaded per batch when scrolling up
  MESSAGES_PER_PAGE = 20

  # get the opposite user of the conversation
  def private_conv_recipient(conversation)
    conversation.opposed_user(current_user)
  end

  def group_conversation?(conversation)
    conversation.is_a?(Group::Conversation)
  end

  # the latest messages, oldest first
  def private_conversation_messages(conversation)
    conversation.messages.includes(:user).order(id: :desc).limit(MESSAGES_PER_PAGE).to_a.reverse
  end

  # if the conversation has older messages than the ones shown, load them when scrolling up
  def load_private_messages(conversation, messages)
    if messages.any? && conversation.messages.where(id: ...messages.first.id).exists?
      "private/messages/load_more_messages"
    else
      "shared/empty_partial"
    end
  end

  def conversation_message_partial(conversation)
    group_conversation?(conversation) ? "group/messages/message" : "private/messages/message"
  end

  # For groups: the last message the current user has read, to mark newer ones unseen
  def conversation_last_read_id(conversation)
    return unless group_conversation?(conversation)

    conversation.membership_for(current_user)&.last_read_message_id || 0
  end

  # Paths
  def conversation_messages_path(conversation, **query)
    if group_conversation?(conversation)
      group_messages_path(conversation_id: conversation.id, **query)
    else
      private_messages_path(conversation_id: conversation.id, **query)
    end
  end

  def conversation_create_message_path(conversation)
    group_conversation?(conversation) ? group_messages_path : private_messages_path
  end

  def conversation_mark_as_seen_path(conversation)
    if group_conversation?(conversation)
      mark_as_seen_group_conversation_path(conversation)
    else
      mark_as_seen_private_conversation_path(conversation)
    end
  end

  # DOM ids, shared by the views and the Turbo Stream responses
  def conversation_prefix(conversation)
    group_conversation?(conversation) ? "gc" : "pc"
  end

  def conversation_window_id(conversation)
    "#{conversation_prefix(conversation)}#{conversation.id}"
  end

  def conversation_messages_id(conversation)
    "#{conversation_window_id(conversation)}-messages"
  end

  def conversation_form_id(conversation)
    "#{conversation_window_id(conversation)}-form"
  end

  def conversation_load_more_id(conversation)
    "#{conversation_window_id(conversation)}-load-more"
  end
end
