require "test_helper"

class NavigationHelperTest < ActionView::TestCase
  include NavigationHelper

  test "returns the signed in links partial for a signed in user" do
    @signed_in = true
    assert_equal "layouts/navigation/collapsible_elements/signed_in_links",
                 collapsible_links_partial_path
  end

  test "returns the non signed in links partial for a guest" do
    @signed_in = false
    assert_equal "layouts/navigation/collapsible_elements/non_signed_in_links",
                 collapsible_links_partial_path
  end

  private

  def user_signed_in?
    @signed_in
  end
end
