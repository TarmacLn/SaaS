# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Categories are needed in every environment
def seed_categories
  {
    "hobby" => [ "Arts", "Crafts", "Sports", "Sciences", "Collecting", "Reading", "Other" ],
    "study" => [ "Arts and Humanities", "Physical Science and Engineering", "Math and Logic",
                 "Computer Science", "Data Science", "Economics and Finance", "Business",
                 "Social Sciences", "Language", "Other" ],
    "team"  => [ "Study", "Development", "Arts and Hobby", "Other" ]
  }.each do |branch, names|
    names.each { |name| Category.find_or_create_by!(name: name, branch: branch) }
  end
end

# Sample users and posts, for development only
def seed_users
  10.times do |i|
    User.find_or_create_by!(email: "test#{i}@test.com") do |user|
      user.name = "test#{i}"
      user.password = "123456"
    end
  end
end

def seed_posts
  return if Post.exists?

  users = User.all.to_a
  Category.find_each do |category|
    5.times do
      Post.create!(
        title: Faker::Lorem.sentence,
        content: Faker::Lorem.paragraph(sentence_count: 4),
        user: users.sample,
        category: category
      )
    end
  end
end

seed_categories

if Rails.env.development?
  seed_users
  seed_posts
end
