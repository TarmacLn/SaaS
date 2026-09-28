require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "local_time_tag renders the time in UTC for the browser to convert" do
    time = Time.utc(2026, 9, 28, 14, 38)
    html = Nokogiri::HTML.fragment(local_time_tag(time.in_time_zone("Athens")))
    tag = html.at("time")

    assert_equal "2026-09-28T14:38:00Z", tag["datetime"]
    assert_equal "local-time", tag["data-controller"]
    assert_equal "short", tag["data-local-time-format-value"]
    assert_equal "Sep 28, 17:38", tag.text, "fallback text uses the app's default zone (Athens)"
  end

  test "local_time_tag can keep custom text and pass extra attributes" do
    tag = Nokogiri::HTML.fragment(
      local_time_tag(Time.utc(2026, 1, 1), format: :title, text: "5 minutes ago", class: "post-time")
    ).at("time")

    assert_equal "5 minutes ago", tag.text
    assert_equal "title", tag["data-local-time-format-value"]
    assert_equal "post-time", tag["class"]
  end
end
