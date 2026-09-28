class ApplicationController < ActionController::Base
  include Pagy::Method
  include OpenedConversations

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :opened_conversations_windows

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  def opened_conversations_windows
    if user_signed_in?
      # opened conversations, newest first; only ones this user takes part in
      conversations = Private::Conversation.for_user(current_user)
                                           .includes(:sender, :recipient)
                                           .where(id: opened_conversation_ids)
                                           .index_by(&:id)
      @private_conversations_windows = opened_conversation_ids.reverse.filter_map { |id| conversations[id] }
    else
      @private_conversations_windows = []
    end
  end
end
