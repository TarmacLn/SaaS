# Refreshes a user's navbar conversations menu, unread badge and messenger list (all their tabs).
# Shared by private and group conversations.
module ConversationsMenuBroadcasts
  extend ActiveSupport::Concern

  def broadcast_menu_to(user)
    menu = Private::ConversationsMenu.new(user)
    navbar_menu = Private::ConversationsMenu.new(user, limit: Private::ConversationsMenu::NAVBAR_LIMIT)

    Turbo::StreamsChannel.broadcast_replace_to user, :private_conversations,
                                               target: "unseen-conversations",
                                               partial: "private/conversations/menu/unseen_badge",
                                               locals: { menu: menu }
    Turbo::StreamsChannel.broadcast_update_to user, :private_conversations,
                                              target: "conversations-menu-items",
                                              partial: "private/conversations/menu/items",
                                              locals: { menu: navbar_menu }
    Turbo::StreamsChannel.broadcast_update_to user, :private_conversations,
                                              target: "messenger-conversations",
                                              partial: "messengers/conversations_list",
                                              locals: { menu: menu, selected: nil }
  end
end
