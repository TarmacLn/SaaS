class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]
  has_many :posts, dependent: :destroy

  has_many :private_messages, class_name: "Private::Message", dependent: :destroy
  has_many :private_conversations,
           foreign_key: :sender_id,
           class_name: "Private::Conversation",
           dependent: :destroy
  # Conversations other users started with this user; needed so deleting a user
  # also removes those (their foreign key points at this user too)
  has_many :received_private_conversations,
           foreign_key: :recipient_id,
           class_name: "Private::Conversation",
           dependent: :destroy

  # Group conversations
  has_many :group_messages, class_name: "Group::Message", dependent: :destroy
  has_many :group_memberships, class_name: "Group::Membership", dependent: :destroy
  has_many :group_conversations, through: :group_memberships, source: :conversation

  # Contacts: requests this user sent (contacts) and received (all_received_contact_requests)
  has_many :contacts, dependent: :destroy
  has_many :all_received_contact_requests, class_name: "Contact", foreign_key: :contact_id, dependent: :destroy

  has_many :accepted_sent_contact_requests, -> { where(contacts: { accepted: true }) },
           through: :contacts, source: :contact
  has_many :accepted_received_contact_requests, -> { where(contacts: { accepted: true }) },
           through: :all_received_contact_requests, source: :user
  has_many :pending_sent_contact_requests, -> { where(contacts: { accepted: false }) },
           through: :contacts, source: :contact
  has_many :pending_received_contact_requests, -> { where(contacts: { accepted: false }) },
           through: :all_received_contact_requests, source: :user

  # Users who are this user's contacts, whoever sent the request
  def all_active_contacts
    User.where(id: accepted_sent_contact_requests.select(:id))
        .or(User.where(id: accepted_received_contact_requests.select(:id)))
  end

  # Users with a contact request not accepted yet, sent or received
  def all_pending_contacts
    User.where(id: pending_sent_contact_requests.select(:id))
        .or(User.where(id: pending_received_contact_requests.select(:id)))
  end

  def contact_with?(user)
    all_active_contacts.exists?(user.id)
  end

  # The user for a Google login (auth is OmniAuth's auth hash): the one who used this Google
  # account before, else an existing account with the same *verified* email (linked to Google),
  # else a new account. Returns an unsaved user with errors if it can't be saved.
  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    email = auth.info.email.to_s.downcase
    verified = ActiveModel::Type::Boolean.new.cast(auth.extra&.raw_info&.email_verified)

    user = find_by(email: email) if verified && email.present?
    if user
      user.update(provider: auth.provider, uid: auth.uid)
      return user
    end

    user = new(provider: auth.provider, uid: auth.uid, email: email,
               name: auth.info.name.presence || email.split("@").first,
               password: Devise.friendly_token[0, 32])
    user.save
    user
  end

  # Has logged in with Google (the account was created or linked through it)
  def google_account?
    provider == "google_oauth2"
  end
end
