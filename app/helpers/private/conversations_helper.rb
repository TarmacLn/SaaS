module Private::ConversationsHelper
  MESSAGES_IN_WINDOW = 30

  # get the opposite user of the conversation
  def private_conv_recipient(conversation)
    conversation.opposed_user(current_user)
  end

  # the latest messages, oldest first; uses the preloaded messages when available
  def private_conversation_messages(conversation)
    conversation.messages.sort_by { |message| [ message.created_at, message.id ] }.last(MESSAGES_IN_WINDOW)
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
end
