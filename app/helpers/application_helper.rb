module ApplicationHelper
  include NavigationHelper
  # Conversation windows are rendered on every page
  include Private::ConversationsHelper
  include Private::MessagesHelper
  include ContactsHelper

  # First letter of a user's name for their avatar circle, "?" when they have no name
  def user_initial(user)
    user.name.to_s.strip.first.presence&.upcase || "?"
  end

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
