require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "fixture user is valid" do
    assert users(:one).valid?
  end

  test "requires an email" do
    user = User.new(name: "No Email", password: "password")
    assert_not user.valid?
    assert user.errors.added?(:email, :blank)
  end

  test "requires a unique email regardless of case" do
    user = User.new(name: "Copy", email: users(:one).email.upcase, password: "password")
    assert_not user.valid?
    assert user.errors.added?(:email, :taken, value: users(:one).email)
  end

  test "requires a password of at least 6 characters" do
    user = User.new(name: "Short", email: "short@example.com", password: "12345")
    assert_not user.valid?
    assert user.errors.of_kind?(:password, :too_short)
  end

  test "has many posts" do
    assert_equal [ posts(:hobby_post), posts(:study_post) ].sort, users(:one).posts.sort
  end

  test "deleting a user deletes their posts" do
    user = users(:one)
    assert_difference "Post.count", -user.posts.count do
      user.destroy
    end
  end

  test "has private conversations it started and messages it sent" do
    assert_equal [ private_conversations(:one_and_two) ], users(:one).private_conversations.to_a
    assert_equal [ private_messages(:hello) ], users(:one).private_messages.to_a
  end

  test "deleting a user deletes their conversations, including ones they received" do
    assert_difference({ "Private::Conversation.count" => -1, "Private::Message.count" => -2 }) do
      users(:two).destroy
    end
  end

  test "sent and received contact requests" do
    assert_equal [ contacts(:one_and_two) ], users(:one).contacts.to_a
    assert_equal [ contacts(:three_asks_one) ], users(:one).all_received_contact_requests.to_a
  end

  test "accepted contacts, from either side" do
    assert_equal [ users(:two) ], users(:one).accepted_sent_contact_requests.to_a
    assert_equal [ users(:one) ], users(:two).accepted_received_contact_requests.to_a
  end

  test "pending contact requests, from either side" do
    assert_equal [ users(:one) ], users(:three).pending_sent_contact_requests.to_a
    assert_equal [ users(:three) ], users(:one).pending_received_contact_requests.to_a
  end

  test "all_active_contacts includes contacts whoever sent the request" do
    assert_equal [ users(:two) ], users(:one).all_active_contacts.to_a
    assert_equal [ users(:one) ], users(:two).all_active_contacts.to_a
    assert_empty users(:three).all_active_contacts

    contacts(:three_asks_one).accept!
    assert_equal [ users(:two), users(:three) ].sort, users(:one).all_active_contacts.to_a.sort
  end

  test "all_pending_contacts includes requests sent and received" do
    assert_equal [ users(:three) ], users(:one).all_pending_contacts.to_a
    assert_equal [ users(:one) ], users(:three).all_pending_contacts.to_a
    assert_empty users(:two).all_pending_contacts
  end

  test "contact_with? is true only for accepted contacts" do
    assert users(:one).contact_with?(users(:two))
    assert users(:two).contact_with?(users(:one))
    assert_not users(:one).contact_with?(users(:three)), "still pending"
  end

  test "deleting a user deletes their sent and received contact requests" do
    assert_difference "Contact.count", -2 do
      users(:one).destroy
    end
  end
end
