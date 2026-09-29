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

DEMO_NAMES = [
  "Maria Papadopoulou", "Giorgos Nikolaou", "Eleni Georgiou", "Nikos Dimitriou", "Katerina Ioannou",
  "Kostas Vasileiou", "Sofia Konstantinou", "Dimitris Alexiou", "Anna Christodoulou", "Petros Makris"
].freeze

# test0 ... test9, with real-sounding names (older databases have "test0" etc. as names)
def seed_users
  DEMO_NAMES.each_with_index.map do |name, i|
    user = User.find_or_initialize_by(email: "test#{i}@test.com")
    user.password = "123456" if user.new_record?
    user.name = name if user.new_record? || user.name.match?(/\Atest\d\z/)
    user.save!
    user
  end
end

# [branch, category, author index, days ago, title, content]
DEMO_POSTS = [
  [ "hobby", "Sports", 2, 1, "Looking for a tennis partner on weekends",
    "I play at an intermediate level and I'm looking for someone to play with on Saturday or Sunday mornings at the university courts. Beginners who want to improve are welcome too!" ],
  [ "hobby", "Sports", 5, 4, "Anyone up for a 5-a-side football game?",
    "We have a pitch booked every Wednesday at 19:00 and we're missing two or three players. No need to be a pro, we play for fun." ],
  [ "hobby", "Sports", 6, 9, "Morning running group near the campus",
    "Running 5-7 km three times a week at 7:30, around the park next to the campus. Easy pace, we mostly chat while running." ],
  [ "hobby", "Arts", 8, 3, "Sketching meetups in the old town",
    "Every other Sunday I go sketching buildings and street scenes in the old town. Bring a sketchbook and a pencil, that's all you need." ],
  [ "hobby", "Arts", 4, 12, "Learning watercolour, looking for company",
    "I just started with watercolours and it's more fun with other people. Thinking of weekly sessions where we try tutorials together." ],
  [ "hobby", "Crafts", 6, 15, "Knitting beginners circle",
    "Cosy knitting evenings at the library cafe. I can teach the basics, and if you already knit you can help the rest of us!" ],
  [ "hobby", "Sciences", 3, 6, "Amateur astronomy night this Friday",
    "Clear skies are forecast for Friday. I'm taking my telescope to the hill behind the dorms to look at Saturn and Jupiter. Join if you like!" ],
  [ "hobby", "Collecting", 9, 18, "Trading vinyl records",
    "I collect 70s and 80s rock vinyl and have some doubles to trade. Always happy to meet other collectors and talk about music." ],
  [ "hobby", "Reading", 2, 2, "Starting a sci-fi book club",
    "First book: 'The Left Hand of Darkness' by Ursula K. Le Guin. We'd meet once a month to discuss it over coffee." ],
  [ "hobby", "Reading", 7, 20, "Who wants to read 'Sapiens' together?",
    "I've been meaning to read Sapiens for ages. Looking for one or two people to read a few chapters a week and discuss them." ],
  [ "hobby", "Other", 1, 5, "Board game evenings every Thursday",
    "We play Catan, Ticket to Ride, Codenames and more at the student club every Thursday from 20:00. New players always welcome." ],
  [ "study", "Computer Science", 1, 1, "Study group for the Algorithms exam",
    "The Algorithms exam is in three weeks. I'd like to form a small group to go through past papers, especially dynamic programming and graphs." ],
  [ "study", "Computer Science", 7, 7, "Need help understanding recursion",
    "I understand simple examples, but I get lost with recursive tree problems. Could someone explain it over a coffee? Happy to help with SQL in return." ],
  [ "study", "Computer Science", 3, 10, "Ruby on Rails practice partner",
    "I'm learning Ruby on Rails for the Service Oriented Software course and would love someone to pair program with once or twice a week." ],
  [ "study", "Math and Logic", 4, 4, "Linear algebra problem sets together",
    "Looking for people to solve the weekly linear algebra problem sets together. Eigenvalues are killing me." ],
  [ "study", "Math and Logic", 9, 14, "Discrete math tutoring swap",
    "I'm good at discrete math but struggle with probability. Anyone want to swap tutoring sessions?" ],
  [ "study", "Data Science", 5, 3, "Kaggle beginners: let's do a competition",
    "Want to join a beginner Kaggle competition as a team? I know some pandas and scikit-learn, and it's a great way to learn." ],
  [ "study", "Physical Science and Engineering", 8, 11, "Physics II lab report partner",
    "Our lab reports are done in pairs and my partner dropped the course. Looking for someone in the Tuesday lab group." ],
  [ "study", "Economics and Finance", 6, 8, "Microeconomics revision sessions",
    "Revision sessions before the midterm: supply and demand, elasticity and market structures. Thursdays at the library." ],
  [ "study", "Language", 2, 5, "German A2 conversation practice",
    "I'm preparing for the A2 exam and need speaking practice. Let's meet and chat in German, mistakes allowed!" ],
  [ "study", "Language", 0, 13, "Tandem: Greek for Spanish",
    "I'm a native Greek speaker learning Spanish. Looking for a Spanish speaker who wants to learn or practise Greek." ],
  [ "study", "Business", 5, 16, "Case study practice for consulting interviews",
    "Practising case interviews for internships. Looking for a partner to take turns being the interviewer." ],
  [ "study", "Social Sciences", 4, 19, "Research methods: survey design help",
    "Designing a questionnaire for my research methods project. Would appreciate feedback from someone who has done it before." ],
  [ "study", "Arts and Humanities", 7, 21, "Philosophy reading group: Plato's Republic",
    "Reading one book of the Republic every two weeks and discussing it. No philosophy background needed." ],
  [ "team", "Development", 3, 2, "Looking for a backend developer for a Rails app",
    "We're building a collaboration portal for students and need someone comfortable with Rails, PostgreSQL and Action Cable." ],
  [ "team", "Development", 9, 6, "Frontend dev wanted for the hackathon",
    "Our team for next month's hackathon has two backend developers and a designer. We need someone good with HTML, CSS and JavaScript." ],
  [ "team", "Development", 1, 12, "Mobile app idea: need a designer and a developer",
    "I have an idea for an app that helps students find study rooms on campus. Looking for a designer and a mobile developer to build an MVP." ],
  [ "team", "Study", 0, 3, "Group project partner for Software Engineering",
    "The Software Engineering course project is in teams of two. I'm organised and like writing tests, looking for a reliable partner." ],
  [ "team", "Study", 8, 9, "Team for the Databases semester project",
    "We're two people looking for a third member for the Databases project: design a schema and build a small app on top of it." ],
  [ "team", "Arts and Hobby", 5, 7, "Guitarist wanted for a student band",
    "We play indie rock and have a drummer, a bassist and a singer. Rehearsals once a week, first gig at the spring festival." ],
  [ "team", "Arts and Hobby", 6, 17, "Photographer for the university magazine",
    "The student magazine needs a photographer for events and interviews. A phone camera is fine if you have a good eye!" ],
  [ "team", "Other", 2, 10, "Volunteers for the campus coding workshop",
    "We're running a free coding workshop for high school students. Looking for volunteers to help as mentors for a Saturday." ]
].freeze

def seed_posts(users)
  return if Post.exists?

  categories = Category.all.index_by { |category| [ category.branch, category.name ] }
  DEMO_POSTS.each_with_index do |(branch, category, author, days_ago, title, content), i|
    created_at = days_ago.days.ago - (i * 37).minutes
    Post.create!(title: title, content: content, user: users[author],
                 category: categories.fetch([ branch, category ]),
                 created_at: created_at, updated_at: created_at)
  end
end

# Contacts, private conversations and groups. Inserted directly (insert_all) with timestamps in the
# past, which also skips the real-time broadcasts nobody is listening to while seeding.
def seed_social(users)
  return if Contact.exists? || Private::Conversation.exists? || Group::Conversation.exists?

  # accepted contacts [a, b], and pending requests [from, to]
  accepted = [ [ 0, 1 ], [ 0, 2 ], [ 0, 3 ], [ 0, 5 ], [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 5 ], [ 2, 6 ],
               [ 3, 7 ], [ 3, 9 ], [ 4, 8 ], [ 5, 9 ], [ 6, 8 ], [ 7, 9 ] ]
  pending = [ [ 4, 0 ], [ 7, 0 ], [ 0, 9 ], [ 8, 1 ] ]
  Contact.insert_all!(
    accepted.map { |a, b| { user_id: users[a].id, contact_id: users[b].id, accepted: true, created_at: 10.days.ago, updated_at: 10.days.ago } } +
    pending.map { |a, b| { user_id: users[a].id, contact_id: users[b].id, accepted: false, created_at: 1.day.ago, updated_at: 1.day.ago } }
  )

  # Private conversations: sender, recipient, messages [author, minutes ago, text],
  # and how many of the last messages the recipient hasn't read yet
  [
    [ 1, 0, [ [ 1, 2900, "Hi Maria! I saw your post about the Software Engineering project. Have you found a partner yet?" ],
              [ 0, 2880, "Hi Giorgos! Not yet, are you interested?" ],
              [ 1, 2870, "Yes! I'm taking the course too and I like writing tests as well :)" ],
              [ 0, 2860, "Perfect, let's meet on Monday after the lecture to plan it." ],
              [ 1, 45, "Also, are you joining the Algorithms study group? We start this week." ],
              [ 1, 44, "I added you to the group chat just in case." ] ], 2 ],
    [ 0, 2, [ [ 0, 1500, "Hey Eleni, I'd love to play tennis this weekend!" ],
              [ 2, 1480, "Great! Saturday at 10 at the university courts?" ],
              [ 0, 1470, "Works for me. I'll bring the balls." ],
              [ 2, 1460, "See you there!" ] ], 0 ],
    [ 3, 0, [ [ 3, 300, "Hi Maria, we're looking for someone for our Rails collaboration portal. Would you be interested?" ],
              [ 3, 298, "We use Action Cable for real-time chat, it's a fun project." ] ], 2 ],
    [ 5, 0, [ [ 5, 4000, "Thanks for the notes from the microeconomics lecture!" ],
              [ 0, 3990, "No problem, good luck with the midterm!" ] ], 0 ],
    [ 1, 4, [ [ 1, 600, "Hi Katerina, do you still need help with linear algebra?" ],
              [ 4, 590, "Yes please! Eigenvalues are really confusing me." ] ], 0 ],
    [ 2, 6, [ [ 6, 900, "Are you coming to the morning run tomorrow?" ],
              [ 2, 880, "Yes, see you at 7:30!" ] ], 0 ]
  ].each do |sender, recipient, messages, unread|
    conversation = Private::Conversation.create!(sender: users[sender], recipient: users[recipient])
    rows = messages.each_with_index.map do |(author, minutes_ago, body), index|
      time = minutes_ago.minutes.ago
      { conversation_id: conversation.id, user_id: users[author].id, body: body,
        seen: index < messages.size - unread, created_at: time, updated_at: time }
    end
    Private::Message.insert_all!(rows)
    conversation.update_columns(created_at: rows.first[:created_at], updated_at: rows.last[:created_at])
  end

  # Group conversations: name, members, messages [author, minutes ago, text], and whether
  # test0 has read the latest messages
  [
    [ "Algorithms study group", [ 0, 1, 2, 3 ],
      [ [ 1, 1440, "Welcome everyone! Let's prepare for the Algorithms exam together." ],
        [ 2, 1430, "Great idea. Should we start with dynamic programming?" ],
        [ 3, 1420, "Yes, and graphs after that. I have past papers from last year." ],
        [ 0, 1410, "Count me in! Library, Wednesday at 18:00?" ],
        [ 1, 90, "Wednesday works. I booked room B204." ],
        [ 3, 30, "I'll bring the past papers and some snacks." ] ], false ],
    [ "Weekend hiking crew", [ 0, 2, 5, 6 ],
      [ [ 5, 5000, "Hike to Mount Panachaiko this Sunday?" ],
        [ 6, 4990, "I'm in! What time do we leave?" ],
        [ 2, 4980, "8:00 from the main square, bring water and a sandwich." ],
        [ 0, 4970, "Sounds great, see you all there." ] ], true ],
    [ "Web app team project", [ 1, 3, 7, 9 ],
      [ [ 3, 700, "Let's split the work: backend, frontend and tests." ],
        [ 7, 690, "I'll take the frontend." ],
        [ 9, 680, "I can do the database design and the seeds." ],
        [ 1, 670, "Then I'll write the tests. Let's meet on Friday." ] ], true ]
  ].each do |name, member_indexes, messages, test0_read_all|
    group = Group::Conversation.new(name: name)
    member_indexes.each { |i| group.memberships.build(user: users[i]) }
    group.save!

    rows = messages.map do |author, minutes_ago, body|
      time = minutes_ago.minutes.ago
      { conversation_id: group.id, user_id: users[author].id, body: body, created_at: time, updated_at: time }
    end
    ids = Group::Message.insert_all!(rows, returning: [ :id ]).rows.flatten

    # everyone has read everything, except test0 in groups marked unread (the last two messages)
    group.memberships.each do |membership|
      last_read = membership.user == users[0] && !test0_read_all ? ids[-3] : ids.last
      membership.update_columns(last_read_message_id: last_read)
    end
    group.update_columns(created_at: rows.first[:created_at], updated_at: rows.last[:created_at])
  end
end

seed_categories

if Rails.env.development?
  users = seed_users
  seed_posts(users)
  seed_social(users)
end
