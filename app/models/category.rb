class Category < ApplicationRecord
  BRANCHES = %w[hobby study team].freeze

  has_many :posts

  validates :name, presence: true
  validates :branch, inclusion: { in: BRANCHES }
end
