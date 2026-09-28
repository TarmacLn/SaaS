class Private::ConversationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = Post.find(params[:post_id])
    conversation = Private::Conversation.new(sender: current_user, recipient: @post.user)
    message = conversation.messages.build(user: current_user, body: params[:message_body])

    if conversation.save
      respond_with_partial "posts/show/contact_user/message_form/success"
    else
      respond_with_partial "posts/show/contact_user/message_form/fail", status: :unprocessable_entity,
                           errors: conversation.errors.full_messages + message.errors.full_messages
    end
  end

  private

  def respond_with_partial(partial, status: :ok, errors: [])
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("contact-user", partial: partial, locals: { errors: errors }),
               status: status
      end
      format.html do
        flash_type = errors.empty? ? :notice : :alert
        redirect_to post_path(@post), flash_type => (errors.empty? ? "Message has been sent" : errors.to_sentence)
      end
    end
  end
end
