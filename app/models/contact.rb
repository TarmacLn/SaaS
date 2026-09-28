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

  # the contact record between two users, whoever sent the request
  def self.find_by_users(user_id, contact_id)
    where(user_id: user_id, contact_id: contact_id).or(where(user_id: contact_id, contact_id: user_id))
  end

  def accept!
    update!(accepted: true)
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
end
