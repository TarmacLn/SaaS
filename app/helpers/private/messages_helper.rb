module Private::MessagesHelper
  def sent_or_received(message, user)
    user.id == message.user_id ? "message-sent" : "message-received"
  end

  def seen_or_unseen(message)
    message.seen == false ? "unseen" : ""
  end
end
