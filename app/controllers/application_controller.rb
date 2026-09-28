class ApplicationController < ActionController::Base
  include Pagy::Method
  include OpenedConversations

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :opened_conversations_windows
  before_action :set_conversations_menu

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  def set_conversations_menu
    @conversations_menu = Private::ConversationsMenu.new(current_user, limit: Private::ConversationsMenu::NAVBAR_LIMIT) if user_signed_in?
  end

  def opened_conversations_windows
    if user_signed_in?
      @private_conversations_windows = opened_windows(Private::Conversation.includes(:sender, :recipient))
      @group_conversations_windows = opened_windows(Group::Conversation.all)
    else
      @private_conversations_windows = []
      @group_conversations_windows = []
    end
  end

  # opened conversations, newest first; only ones this user takes part in
  def opened_windows(scope)
    ids = opened_conversation_ids(scope.klass)
    conversations = scope.for_user(current_user).where(id: ids).index_by(&:id)
    ids.reverse.filter_map { |id| conversations[id] }
  end
end
