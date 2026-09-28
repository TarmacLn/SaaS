class Group::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  # Older messages of a group, for scrolling up in its window
  def index
    older = @conversation.messages.includes(:user)
    older = older.where(id: ...params[:before].to_i) if params[:before].present?
    @messages = older.order(id: :desc).limit(Private::ConversationsHelper::MESSAGES_PER_PAGE).to_a.reverse

    respond_to do |format|
      format.turbo_stream { render "private/messages/index" }
    end
  end

  def create
    @message = @conversation.messages.build(user: current_user, body: params[:body])

    if @message.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append(helpers.conversation_messages_id(@conversation),
                                partial: "group/messages/message",
                                locals: { message: @message, viewer: current_user, unseen: false }),
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

  private

  # only groups the user is a member of
  def set_conversation
    @conversation = Group::Conversation.for_user(current_user).find(params[:conversation_id])
  end
end
