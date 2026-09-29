# CollabCafe

A portal where students find people with the same interests, courses or projects, and team up with them.
Post what you're looking for (a hobby buddy, a study partner or a team member), search and filter posts,
add people as contacts, and chat with them in real time, one-to-one or in groups.

Built for the course **Υπηρεσιοστρεφές Λογισμικό (Service Oriented Software), 2025-2026** for University of Piraeus, based on the
[collabfield tutorial](https://www.freecodecamp.org/news/lets-create-an-intermediate-level-ruby-on-rails-application-d7c6e997c63f)
([source](https://github.com/domagude/collabfield)), rebuilt for Rails 8.

Made by Ioanna Andrianou (TarmacLn)

---

## Features

**Posts**
- Create posts in three branches (hobby, study and team) with categories for each
- Search posts by title and content, filter by branch and category, with pagination
- Open a post in a pop-up window, or on its own page, and contact its author

**Accounts**
- Sign up, log in and log out with email and password (Devise)
- Log in with Google (OmniAuth); accounts created with Google have no password
- Edit your profile or delete your account

**Contacts**
- Send, accept and decline contact requests, with a live notification badge
- Your contacts in the home page side menu, one click to message them

**Messaging** (real time with Action Cable)
- Private conversations in pop-up chat windows that stay open while you browse
- Group conversations with your contacts; add more people at any time
- Unread messages highlighted, marked as seen when you read them
- Conversations menu with an unread badge, and a full-page Messenger
- Older messages load as you scroll up; times are shown in each viewer's own time zone

---

## Technologies

| Area | Technology |
|---|---|
| Language / framework | Ruby 3.4.10, Ruby on Rails 8.1 |
| Database | PostgreSQL (developed with 16) |
| Real time | Action Cable with Turbo Streams broadcasts (Solid Cable in production) |
| Front end | Hotwire (Turbo and Stimulus), Importmap (no Node.js build step) |
| Styling | Bootstrap 5.3 compiled with Dart Sass (`dartsass-rails`), Bootstrap Icons, `bootstrap_form` |
| Authentication | Devise 5, OmniAuth with `omniauth-google-oauth2` and `omniauth-rails_csrf_protection` |
| Pagination | Pagy |
| Web server | Puma |
| Tests | Minitest (models, controllers, helpers, integration, channels) with fixtures |
| Code quality and security | RuboCop (Rails Omakase), Brakeman, bundler-audit, `importmap audit` |
| CI | GitHub Actions (`.github/workflows/ci.yml`) |

---

## Requirements

- **Ruby 3.4.10** (see `.ruby-version`), for example with [mise](https://mise.jdx.dev), rbenv or asdf
- **PostgreSQL**, running locally, for example with [Postgres.app](https://postgresapp.com) on macOS or
  `sudo apt install postgresql libpq-dev` on Ubuntu
- **Bundler** (`gem install bundler`)
- Git

Node.js is **not** needed: JavaScript is served with Importmap and Sass is compiled by Dart Sass.

---

## Setup

```bash
git clone https://github.com/TarmacLn/SaaS.git
cd SaaS
bin/setup
```

`bin/setup` installs the gems, creates the database, loads the schema,
**fills the database with demo data** and starts the server. Open <http://localhost:3000>.

`bin/dev` runs the Rails server and the Sass watcher together (see `Procfile.dev`).

### Database connection

`config/database.yml` connects to the local PostgreSQL server as your system user, which works out of the
box with Postgres.app. If your PostgreSQL needs a username, password or host, set them for your shell:

```bash
export PGUSER=postgres PGPASSWORD=postgres PGHOST=localhost
```

### Secrets (`config/master.key`)

The Google login keys are stored encrypted in `config/credentials.yml.enc`. To decrypt them you need
`config/master.key`, which is **not** in git.
Without it the app and the tests still run; only Google login won't work.

---

## Demo data

The seeds (`db/seeds.rb`) create 10 users, realistic posts in every branch, contacts, private
conversations and group chats. All demo accounts use the password **`123456`**:

To reset the development database to fresh demo data (this deletes everything in it):

```bash
bin/rails db:seed:replant
```

---

## Tests and checks

```bash
bin/rails test          # all tests
bin/rubocop             # code style
bin/brakeman            # security scan of the code
bin/bundler-audit       # known vulnerabilities in gems
bin/importmap audit     # known vulnerabilities in JavaScript packages
```

or all of them at once (plus setup and a seeds check) with the local CI script:

```bash
bin/ci
```

The tests use fixtures (`test/fixtures`) and fake Google's replies. 
GitHub Actions runs the same checks on every push and pull request.

---

## Project structure

```
app/
  channels/application_cable/   Action Cable connection (signed-in users only)
  controllers/
    pages_controller.rb          home page: side menu, filters and posts
    posts_controller.rb          branch pages, post page, new post
    contacts_controller.rb       contact requests
    messengers_controller.rb     full-page Messenger
    private/  group/             conversations and messages
    users/                       Google login callback
  models/
    post.rb  category.rb  contact.rb  user.rb
    private/                     Private::Conversation, Private::Message, Private::ConversationsMenu
    group/                       Group::Conversation, Group::Membership, Group::Message
  services/posts_for_branch_service.rb   search and category filtering
  javascript/controllers/        Stimulus: chat windows, post modal, local times, ...
  views/                         ERB templates and partials
  assets/stylesheets/            Sass: base, partials, responsive
db/seeds.rb                      categories everywhere, demo data in development
test/                            Minitest tests and fixtures
```

---

## Useful commands

| Command | What it does |
|---|---|
| `bin/dev` | Start the server and the Sass watcher |
| `bin/rails db:migrate` | Apply new migrations (after pulling) |
| `bin/rails db:seed:replant` | Reset the development data to the demo data |
| `bin/rails console` | Rails console |
| `bin/rails routes` | List all routes |

**Real-time updates in development** use the `async` Action Cable adapter, which only delivers messages
sent from inside the running server. Messages created from `bin/rails console` won't appear live;
everything done through the app does.
