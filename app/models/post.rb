class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :title, presence: true, length: { minimum: 5, maximum: 255 }
  validates :content, presence: true, length: { minimum: 20, maximum: 1000 }

  # id breaks ties between posts created at the same moment, so pages never overlap
  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  scope :by_branch, ->(branch) { joins(:category).where(categories: { branch: branch }) }

  scope :by_category, ->(branch, category_name) do
    joins(:category).where(categories: { branch: branch, name: category_name })
  end

  scope :search, ->(search) do
    pattern = "%#{sanitize_sql_like(search)}%"
    where("posts.title ILIKE :pattern OR posts.content ILIKE :pattern", pattern: pattern)
  end
end
