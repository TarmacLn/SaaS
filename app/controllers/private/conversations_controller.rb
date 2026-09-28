class Private::ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [ :open, :close, :mark_as_seen ]

  def create
    @post = Post.find(params[:post_id])
    @conversation = Private::Conversation.new(sender: current_user, recipient: @post.user)
    message = @conversation.messages.build(user: current_user, body: params[:message_body])

    if @conversation.save
      add_to_conversations(@conversation)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("contact-user", partial: "posts/show/contact_user/message_form/success"),
            open_window_stream
          ]
        end
        format.html { redirect_to post_path(@post), notice: "Message has been sent" }
      end
    else
      errors = @conversation.errors.full_messages + message.errors.full_messages
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("contact-user",
                                                    partial: "posts/show/contact_user/message_form/fail",
                                                    locals: { errors: errors }),
                 status: :unprocessable_entity
        end
        format.html { redirect_to post_path(@post), alert: errors.to_sentence }
      end
    end
  end

  # Open the conversation with one of the user's contacts, starting it if they never talked
  def start
    other = current_user.all_active_contacts.find(params[:user_id])
    @conversation = Private::Conversation.between_users(current_user.id, other.id).first ||
                    Private::Conversation.create!(sender: current_user, recipient: other)
    add_to_conversations(@conversation)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: open_window_stream }
      format.html { redirect_to messenger_path(conversation_id: @conversation.id) }
    end
  end

  # Show a conversation's window (again)
  def open
    add_to_conversations(@conversation)
    respond_to do |format|
      # windows opened by an incoming message start collapsed (?expanded=false)
      format.turbo_stream { render turbo_stream: open_window_stream(expanded: params[:expanded] != "false") }
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def close
    remove_from_conversations(@conversation)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(helpers.conversation_window_id(@conversation)) }
      format.html { redirect_back fallback_location: root_path }
    end
  end

  # The other person's messages have been read (window opened or clicked)
  def mark_as_seen
    @conversation.broadcast_menu_to(current_user) if @conversation.mark_as_seen_by(current_user).positive?
    head :no_content
  end

  private

  def set_conversation
    @conversation = Private::Conversation.for_user(current_user).find(params[:id])
  end

  # Newest window goes first (right-most); an already open one is moved there
  def open_window_stream(expanded: true)
    turbo_stream.prepend("conversations-windows",
                         partial: "private/conversations/conversation",
                         locals: { conversation: @conversation, user: current_user, expanded: expanded })
  end
end
