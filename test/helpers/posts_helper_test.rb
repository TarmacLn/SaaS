require "test_helper"

class PostsHelperTest < ActionView::TestCase
  attr_accessor :signed_in_user

  def user_signed_in?
    signed_in_user.present?
  end

  def current_user
    signed_in_user
  end

  test "contact_user_partial_path returns the contact form partial for someone else's post" do
    self.signed_in_user = users(:two)
    @post = posts(:hobby_post)
    assert_equal "posts/show/contact_user", contact_user_partial_path
  end

  test "contact_user_partial_path returns an empty partial for your own post" do
    self.signed_in_user = users(:one)
    @post = posts(:hobby_post)
    assert_equal "shared/empty_partial", contact_user_partial_path
  end

  test "contact_user_partial_path asks guests to log in" do
    self.signed_in_user = nil
    @post = posts(:hobby_post)
    assert_equal "posts/show/login_required", contact_user_partial_path
  end

  test "leave_message_partial_path returns already_in_touch when a message was sent" do
    @message_has_been_sent = true
    assert_equal "posts/show/contact_user/already_in_touch", leave_message_partial_path
  end

  test "leave_message_partial_path returns the message form otherwise" do
    @message_has_been_sent = false
    assert_equal "posts/show/contact_user/message_form", leave_message_partial_path
  end

  test "post_card_actions_partial_path depends on who is looking" do
    self.signed_in_user = nil
    assert_equal "posts/card_actions/guest", post_card_actions_partial_path(posts(:hobby_post))

    self.signed_in_user = users(:one)
    assert_equal "posts/card_actions/own_post", post_card_actions_partial_path(posts(:hobby_post))
    assert_equal "posts/card_actions/interested", post_card_actions_partial_path(posts(:team_post))
  end
end
