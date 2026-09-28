module Private::ConversationsHelper
  # Messages shown when a window opens, and loaded per batch when scrolling up
  MESSAGES_PER_PAGE = 20

  # get the opposite user of the conversation
  def private_conv_recipient(conversation)
    conversation.opposed_user(current_user)
  end

  # the latest messages, oldest first
  def private_conversation_messages(conversation)
    conversation.messages.order(id: :desc).limit(MESSAGES_PER_PAGE).to_a.reverse
  end

  # if the conversation has older messages than the ones shown, load them when scrolling up
  def load_private_messages(conversation, messages)
    if messages.any? && conversation.messages.where(id: ...messages.first.id).exists?
      "private/messages/load_more_messages"
    else
      "shared/empty_partial"
    end
  end

  # DOM ids, shared by the views and the Turbo Stream responses
  def conversation_window_id(conversation)
    "pc#{conversation.id}"
  end

  def conversation_messages_id(conversation)
    "pc#{conversation.id}-messages"
  end

  def conversation_form_id(conversation)
    "pc#{conversation.id}-form"
  end

  def conversation_load_more_id(conversation)
    "pc#{conversation.id}-load-more"
  end
end
