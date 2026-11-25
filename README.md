# Inventory

A web app for tracking anything: office equipment, library books, HR documents.
An owner creates an inventory (a template with its own fields and ID format), and other users fill it with items.

**Features:** custom item IDs built from parts (text, random numbers, GUID, date, sequence) with a live preview;
up to 3 custom fields of each type; public or per-user write access; real-time discussion; likes;
full-text search; statistics; CSV export; admin panel; Google, GitHub and email sign-in; English/Ukrainian UI; light/dark theme.

**Stack:** Rails 8.1, PostgreSQL, Hotwire, Bootstrap 5, Devise + OmniAuth, pg_search, SortableJS, Tom Select, Cloudinary.

## Run locally

```bash
bundle install
cp .env.example .env    # optional: OAuth and Cloudinary keys
bin/rails db:prepare
bin/rails server        # http://localhost:3000
```

Make a user an admin:

```bash
bin/rails runner 'User.find_by(email: "you@example.com").update!(admin: true)'
```

## Tests

```bash
bin/rails test
bundle exec rubocop
```

## Deploy

`render.yaml` describes the Render setup (web service + free Postgres). Set `RAILS_MASTER_KEY` and the keys from `.env.example` in the Render dashboard.
