# A contact request from user to contact. Once the contact accepts it (accepted: true),
# the two users are each other's contacts.
class Contact < ApplicationRecord
  belongs_to :user
  belongs_to :contact, class_name: "User"

  validates :user_id, uniqueness: { scope: :contact_id }
  validate :not_yourself
  validate :unique_pair_of_users

  scope :accepted, -> { where(accepted: true) }
  scope :pending, -> { where(accepted: false) }

  after_commit :broadcast_changes

  # the contact record between two users, whoever sent the request
  def self.find_by_users(user_id, contact_id)
    where(user_id: user_id, contact_id: contact_id).or(where(user_id: contact_id, contact_id: user_id))
  end

  def accept!
    update!(accepted: true)
  end

  # The other user of the request, from the given user's side
  def other_user(viewer)
    User.find_by(id: viewer.id == user_id ? contact_id : user_id)
  end

  # Parts of the page that show this request, for one of its two users:
  # the navbar requests menu, the side menu contacts list and the conversation window's button
  def ui_updates_for(viewer)
    other = other_user(viewer)
    updates = [
      { action: :replace, target: "contact-requests-badge", partial: "contacts/requests_badge", locals: { user: viewer } },
      { action: :update, target: "contact-requests-items", partial: "contacts/request_items", locals: { user: viewer } },
      { action: :update, target: "contacts-list", partial: "contacts/list", locals: { user: viewer } }
    ]
    conversation = other && Private::Conversation.between_users(viewer.id, other.id).first
    if conversation
      updates << { action: :update, target: "pc#{conversation.id}-contact-button",
                   partial: "contacts/window_button", locals: { viewer: viewer, other: other } }
    end
    updates
  end

  private

  def not_yourself
    errors.add(:contact, "can't be yourself") if user_id.present? && user_id == contact_id
  end

  # The unique index only covers user -> contact; also block contact -> user
  def unique_pair_of_users
    if Contact.find_by_users(user_id, contact_id).where.not(id: id).exists?
      errors.add(:base, "A contact request between these users already exists")
    end
  end

  # Live updates for both users (all their tabs) over their own stream.
  # Skips a user deleted in the same transaction (their requests are deleted with them).
  def broadcast_changes
    User.where(id: [ user_id, contact_id ]).each do |viewer|
      ui_updates_for(viewer).each do |update|
        Turbo::StreamsChannel.broadcast_action_to viewer, :private_conversations,
                                                  action: update[:action], target: update[:target],
                                                  partial: update[:partial], locals: update[:locals]
      end
    end
  end
end
