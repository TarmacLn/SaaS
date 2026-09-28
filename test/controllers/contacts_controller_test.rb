require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  # fixtures: one & two are contacts; three asked one (pending)

  test "guest cannot send a contact request" do
    assert_no_difference "Contact.count" do
      post contacts_path(user_id: users(:three).id)
    end
    assert_redirected_to new_user_session_path
  end

  test "sends a contact request" do
    sign_in users(:two)

    assert_difference "Contact.count", 1 do
      post contacts_path(user_id: users(:three).id), as: :turbo_stream
    end

    request = Contact.last
    assert_equal users(:two), request.user
    assert_equal users(:three), request.contact
    assert_not request.accepted
    assert_match %(target="contact-requests-badge"), response.body
  end

  test "cannot send a duplicate or self request" do
    sign_in users(:one)

    assert_no_difference "Contact.count" do
      post contacts_path(user_id: users(:three).id), as: :turbo_stream # three already asked one
      assert_response :unprocessable_entity
      post contacts_path(user_id: users(:one).id), as: :turbo_stream
      assert_response :unprocessable_entity
    end
  end

  test "without Turbo it redirects back with a message" do
    sign_in users(:two)
    post contacts_path(user_id: users(:three).id)

    assert_redirected_to root_path
    assert_equal "Contact request sent", flash[:notice]
  end

  test "the recipient accepts a request" do
    sign_in users(:one)
    patch contact_path(contacts(:three_asks_one)), as: :turbo_stream

    assert_response :success
    assert contacts(:three_asks_one).reload.accepted
    assert users(:one).contact_with?(users(:three))
    assert_match %(target="contacts-list"), response.body
  end

  test "the sender cannot accept their own request" do
    sign_in users(:three)
    patch contact_path(contacts(:three_asks_one)), as: :turbo_stream

    assert_response :not_found
    assert_not contacts(:three_asks_one).reload.accepted
  end

  test "the recipient declines a request" do
    sign_in users(:one)

    assert_difference "Contact.count", -1 do
      delete contact_path(contacts(:three_asks_one)), as: :turbo_stream
    end
  end

  test "the sender cancels a request" do
    sign_in users(:three)

    assert_difference "Contact.count", -1 do
      delete contact_path(contacts(:three_asks_one)), as: :turbo_stream
    end
  end

  test "either side removes a contact" do
    sign_in users(:two)

    assert_difference "Contact.count", -1 do
      delete contact_path(contacts(:one_and_two)), as: :turbo_stream
    end
    assert_not users(:one).contact_with?(users(:two))
  end

  test "others cannot accept someone else's request" do
    sign_in users(:two)
    patch contact_path(contacts(:three_asks_one)), as: :turbo_stream

    assert_response :not_found
    assert_not contacts(:three_asks_one).reload.accepted
  end

  test "others cannot delete someone else's request" do
    sign_in users(:two)

    assert_no_difference "Contact.count" do
      delete contact_path(contacts(:three_asks_one)), as: :turbo_stream
    end
    assert_response :not_found
  end
end
