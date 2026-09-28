class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category

  scope :by_branch, ->(branch) { joins(:category).where(categories: { branch: branch }) }
end
