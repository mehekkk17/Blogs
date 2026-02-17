# NCG Blog (Rails)

Rails app with login/signup and **PostgreSQL** for storing user credentials.

## Requirements

- Ruby 3.x
- PostgreSQL (running locally or via URL)
- Bundler

## Setup

**Run all commands from the project root** (the `NCG Blog app` folder).

1. **Install dependencies**  
   Gems are installed into this project’s `vendor/bundle` so they don’t mix with other apps.
   ```bash
   cd "/Users/mehakmahajan/Desktop/NCG Blog app"
   bundle install
   ```

2. **Create the database** (if you haven’t already)  
   Ensure PostgreSQL is running, then:
   ```bash
   bin/rails db:create
   ```
   Or create it manually: `createdb ncg_blog_development`

3. **Run migrations** (creates the `users` table — required for sign up, login, and every page)
   ```bash
   bin/rails db:migrate
   ```
   Without this, the app will error on every page because the `users` table doesn’t exist yet.

4. **Start the server**
   ```bash
   bin/rails server
   ```
   Open [http://localhost:3000](http://localhost:3000).

## Database (PostgreSQL)

- **Development:** `ncg_blog_development` (config in `config/database.yml`).
- **Production:** set `NCG_BLOG_DATABASE_PASSWORD` and ensure the `ncg_blog` user and `ncg_blog_production` database exist.
- User credentials are stored in the `users` table; passwords are hashed with **bcrypt** (`has_secure_password`).

## Routes

- `GET /` — Home
- `GET /login`, `POST /login` — Sign in
- `DELETE /logout` — Sign out
- `GET /signup`, `POST /users` — Sign up

## One-line setup (after PostgreSQL is installed)

From the project root:

```bash
cd "/Users/mehakmahajan/Desktop/NCG Blog app"
bundle install && bin/rails db:create db:migrate && bin/rails server
```

## Troubleshooting: "Could not find rails-7.2.3... in locally installed gems"

This usually means Bundler installed gems for a different project. Fix it by:

1. Opening a terminal and going to this project’s folder:  
   `cd "/Users/mehakmahajan/Desktop/NCG Blog app"`
2. Installing gems here (they will go into `vendor/bundle`):  
   `bundle install --gemfile Gemfile`
3. Running Rails:  
   `bin/rails db:migrate` or `bin/rails server`

## Troubleshooting: "connection to server on socket ... failed" (PostgreSQL)

PostgreSQL must be installed and running. The app uses `host: localhost` in `config/database.yml` so it connects over TCP (port 5432).

**If PostgreSQL is not installed (or you see "Formula postgresql@14 is not installed"):**

1. Install the default PostgreSQL:
   ```bash
   brew install postgresql
   ```
2. Start it:
   ```bash
   brew services start postgresql
   ```

**If you already have PostgreSQL** (e.g. Postgres.app or a different Homebrew version), start it however you usually do, then run:

```bash
bin/rails db:create   # if the DB doesn’t exist yet
bin/rails db:migrate
```

Check that it’s accepting connections: `pg_isready -h localhost`

## Troubleshooting: "Address already in use" (port 3000)

Another app is already using port 3000. You can either:

**Option A – Use a different port**
```bash
PORT=3001 bin/rails server
```
Then open [http://localhost:3001](http://localhost:3001).

**Option B – Free port 3000**  
Find what’s using it, then stop that process:
```bash
lsof -i :3000 -t   # shows the process ID (e.g. 590)
kill 590           # replace 590 with the ID from above
```
Then run `bin/rails server` again.
