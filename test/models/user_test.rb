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
end
