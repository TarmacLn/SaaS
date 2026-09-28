require "test_helper"

class ContactsUiTest < ActionDispatch::IntegrationTest
  # fixtures: one & two are contacts (and have a conversation); three asked one (pending)

  test "navbar shows pending contact requests with accept and decline" do
    sign_in users(:one)
    get root_path

    assert_select "#contact-requests-menu" do
      assert_select "#contact-requests-badge:not([hidden])", text: /1/
      assert_select "#contact-requests-items .contact-request", count: 1 do
        assert_select ".conversation-item-name", text: users(:three).name
        assert_select "form[action=?] input[name=_method][value=patch]", contact_path(contacts(:three_asks_one))
        assert_select "form[action=?] input[name=_method][value=delete]", contact_path(contacts(:three_asks_one))
      end
    end
  end

  test "the requests badge is hidden without pending requests" do
    sign_in users(:two)
    get root_path

    assert_select "#contact-requests-badge[hidden]"
    assert_select "#contact-requests-items .conversations-empty"
  end

  test "guests have no contact requests menu and see a login hint in the side menu" do
    get root_path

    assert_select "#contact-requests-menu", count: 0
    assert_select "#side-menu .non-signed-in-message"
    assert_select "#side-menu #contacts", count: 0
  end

  test "side menu lists the user's contacts" do
    sign_in users(:one)
    get root_path

    assert_select "#side-menu #contacts-list" do
      assert_select "form[action=?] .contact-item-name", start_private_conversations_path(user_id: users(:two).id),
                    text: users(:two).name
      assert_select ".contact-item-name", text: users(:three).name, count: 0 # still pending
    end
  end

  test "side menu explains how to add contacts when there are none" do
    sign_in users(:three)
    get root_path

    assert_select "#contacts-list .contacts-empty"
  end

  test "clicking a contact opens the existing conversation" do
    sign_in users(:one)

    assert_no_difference "Private::Conversation.count" do
      post start_private_conversations_path(user_id: users(:two).id), as: :turbo_stream
    end
    assert_match %(id="pc#{private_conversations(:one_and_two).id}"), response.body
  end

  test "clicking a contact starts a conversation if they never talked" do
    contacts(:three_asks_one).accept!
    sign_in users(:three)

    assert_difference "Private::Conversation.count", 1 do
      post start_private_conversations_path(user_id: users(:one).id), as: :turbo_stream
    end
    conversation = Private::Conversation.last
    assert_equal [ users(:three), users(:one) ], [ conversation.sender, conversation.recipient ]
  end

  test "cannot start a conversation with someone who isn't a contact" do
    sign_in users(:three) # request to one is still pending

    assert_no_difference "Private::Conversation.count" do
      post start_private_conversations_path(user_id: users(:one).id), as: :turbo_stream
    end
    assert_response :not_found
  end

  test "conversation window shows the contact button for the request's state" do
    conversation = private_conversations(:one_and_two)
    Contact.delete_all
    sign_in users(:one)
    post open_private_conversation_path(conversation), as: :turbo_stream

    get root_path # not contacts yet: add button
    assert_select "#pc#{conversation.id}-contact-button form[action=?]", contacts_path(user_id: users(:two).id)

    request = Contact.create!(user: users(:one), contact: users(:two))
    get root_path # request sent: waiting
    assert_select "#pc#{conversation.id}-contact-button .contact-request-sent"

    request.accept!
    get root_path # contacts: no button
    assert_select "#pc#{conversation.id}-contact-button *", count: 0
  end
end
