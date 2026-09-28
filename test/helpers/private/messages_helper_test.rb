require "test_helper"

class Private::MessagesHelperTest < ActionView::TestCase
  test "sent_or_received tells the user's own messages apart" do
    assert_equal "message-sent", sent_or_received(private_messages(:hello), users(:one))
    assert_equal "message-received", sent_or_received(private_messages(:hello), users(:two))
  end

  test "seen_or_unseen marks messages that haven't been seen" do
    assert_equal "", seen_or_unseen(private_messages(:hello))       # seen: true
    assert_equal "unseen", seen_or_unseen(private_messages(:reply)) # seen: false
  end
end
