require "test_helper"

class ContactsHelperTest < ActionView::TestCase
  test "add_to_contacts_partial_path depends on the request between the users" do
    assert_equal "contacts/window_button/add", add_to_contacts_partial_path(nil, users(:two))
    assert_equal "shared/empty_partial", add_to_contacts_partial_path(contacts(:one_and_two), users(:one))
    assert_equal "contacts/window_button/sent", add_to_contacts_partial_path(contacts(:three_asks_one), users(:three))
    assert_equal "contacts/window_button/received", add_to_contacts_partial_path(contacts(:three_asks_one), users(:one))
  end
end
