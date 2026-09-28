module ContactsHelper
  # Side menu: the contacts list for signed-in users, a login hint for guests
  def contacts_list_partial_path
    user_signed_in? ? "pages/index/contacts" : "pages/index/login_required"
  end

  # Contact button in a conversation window's heading, depending on the request between the two users
  def add_to_contacts_partial_path(contact, viewer)
    if contact.nil?
      "contacts/window_button/add"
    elsif contact.accepted
      "shared/empty_partial"
    elsif contact.user_id == viewer.id
      "contacts/window_button/sent"
    else
      "contacts/window_button/received"
    end
  end
end
