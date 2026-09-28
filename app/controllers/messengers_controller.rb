class MessengersController < ApplicationController
  before_action :authenticate_user!

  def index
    @menu = Private::ConversationsMenu.new(current_user)
    @conversation =
      if params[:conversation_id]
        Private::Conversation.for_user(current_user).includes(:sender, :recipient).find(params[:conversation_id])
      else
        @menu.conversations.first
      end
  end
end
