module ApplicationHelper
  include NavigationHelper
  # Conversation windows are rendered on every page
  include Private::ConversationsHelper
  include Private::MessagesHelper

  # <time> in UTC that the local-time Stimulus controller shows in the viewer's time zone.
  # The text inside is the fallback when JavaScript doesn't run.
  def local_time_tag(time, format: :short, text: nil, **options)
    utc = time.utc
    content_tag :time, text || l(time, format: "%b %-d, %H:%M"),
                datetime: utc.iso8601,
                data: { controller: "local-time", local_time_format_value: format },
                **options
  end
end
