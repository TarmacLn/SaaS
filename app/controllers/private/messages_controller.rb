class Private::MessagesController < ApplicationController
  before_action :authenticate_user!

  # Older messages of a conversation, for scrolling up in its window
  def index
    @conversation = Private::Conversation.for_user(current_user).find(params[:conversation_id])
    older = @conversation.messages
    older = older.where(id: ...params[:before].to_i) if params[:before].present?
    @messages = older.order(id: :desc).limit(Private::ConversationsHelper::MESSAGES_PER_PAGE).to_a.reverse

    respond_to do |format|
      format.turbo_stream
    end
  end

  def create
    @conversation = Private::Conversation.for_user(current_user).find(params[:conversation_id])
    @message = @conversation.messages.build(user: current_user, body: params[:body])

    if @message.save
      @conversation.touch
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append(helpers.conversation_messages_id(@conversation),
                                partial: "private/messages/message",
                                locals: { message: @message, viewer: current_user }),
            turbo_stream.replace(helpers.conversation_form_id(@conversation),
                                 partial: "private/conversations/conversation/new_message_form",
                                 locals: { conversation: @conversation, user: current_user })
          ]
        end
        format.html { redirect_back fallback_location: root_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_back fallback_location: root_path, alert: @message.errors.full_messages.to_sentence }
      end
    end
  end
end
