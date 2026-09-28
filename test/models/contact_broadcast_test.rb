require "test_helper"
require "turbo/broadcastable/test_helper"

class ContactBroadcastTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  def targets_for(user, &block)
    capture_turbo_stream_broadcasts([ user, :private_conversations ], &block).map { |stream| stream["target"] }
  end

  test "a new request updates both users' menus and lists" do
    [ users(:two), users(:three) ].each do |user|
      targets = targets_for(user) { Contact.find_by_users(users(:two).id, users(:three).id).destroy_all
                                    Contact.create!(user: users(:two), contact: users(:three)) }

      assert_includes targets, "contact-requests-badge"
      assert_includes targets, "contact-requests-items"
      assert_includes targets, "contacts-list"
    end
  end

  test "accepting updates the contact button of their conversation window" do
    request = Contact.find_by_users(users(:one).id, users(:two).id).first
    request.update!(accepted: false)

    targets = targets_for(users(:two)) { request.accept! }
    assert_includes targets, "pc#{private_conversations(:one_and_two).id}-contact-button"
  end

  test "deleting a user doesn't break the broadcasts of their requests" do
    assert_nothing_raised { users(:three).destroy }
  end
end
