require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "belongs to the user who sent the request and the contact" do
    contact = contacts(:one_and_two)

    assert_equal users(:one), contact.user
    assert_equal users(:two), contact.contact
  end

  test "is not accepted by default" do
    assert_equal false, Contact.new.accepted
  end

  test "requires a user and a contact" do
    contact = Contact.new
    assert_not contact.valid?
    assert contact.errors.added?(:user, :blank)
    assert contact.errors.added?(:contact, :blank)
  end

  test "cannot add yourself" do
    contact = Contact.new(user: users(:one), contact: users(:one))
    assert_not contact.valid?
    assert_includes contact.errors[:contact], "can't be yourself"
  end

  test "only one request per pair of users, in either direction" do
    assert_not Contact.new(user: users(:one), contact: users(:two)).valid?
    assert_not Contact.new(user: users(:two), contact: users(:one)).valid?
    assert Contact.new(user: users(:two), contact: users(:three)).valid?
  end

  test "an existing contact stays valid" do
    assert contacts(:one_and_two).valid?
  end

  test "the database rejects a duplicate request too" do
    assert_raises(ActiveRecord::RecordNotUnique) do
      Contact.insert!({ user_id: users(:one).id, contact_id: users(:two).id, created_at: Time.current, updated_at: Time.current })
    end
  end

  test "find_by_users finds the request whoever sent it" do
    assert_equal [ contacts(:one_and_two) ], Contact.find_by_users(users(:one).id, users(:two).id).to_a
    assert_equal [ contacts(:one_and_two) ], Contact.find_by_users(users(:two).id, users(:one).id).to_a
    assert_empty Contact.find_by_users(users(:two).id, users(:three).id)
  end

  test "accepted and pending scopes" do
    assert_equal [ contacts(:one_and_two) ], Contact.accepted.to_a
    assert_equal [ contacts(:three_asks_one) ], Contact.pending.to_a
  end

  test "accept! accepts a request" do
    contacts(:three_asks_one).accept!
    assert contacts(:three_asks_one).reload.accepted
  end
end
