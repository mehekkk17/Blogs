# Deploying NCG Blog to Render.com

Use either **Option A** (dashboard) or **Option B** (blueprint).

---

## Option A: Set everything in the Render dashboard

### 1. Create a PostgreSQL database (if you don’t have one)

- Go to **https://dashboard.render.com**
- Click **New +** (top right) → **PostgreSQL**
- Name it (e.g. `ncg-blog-db`), choose **Free**, click **Create Database**
- Wait until it’s **Available**
- Open the database → **Info** (or **Connections**) → copy **Internal Database URL**

### 2. Create a Web Service for the app

- Click **New +** → **Web Service**
- Connect your GitHub/GitLab repo and select this project
- Use these settings:

| Field | Value |
|--------|--------|
| **Name** | `ncg-blog` (or any name) |
| **Region** | Pick one |
| **Branch** | `main` (or your default branch) |
| **Runtime** | **Ruby** |
| **Build Command** | `bundle install` |
| **Start Command** | `bundle exec rails db:migrate && bundle exec puma -C config/puma.rb` |

### 3. Environment variables

In the same Web Service, open **Environment** (left sidebar or tab) and add:

| Key | Value |
|-----|--------|
| `RAILS_ENV` | `production` |
| `SECRET_KEY_BASE` | Run `bin/rails secret` locally and paste the output, or leave blank and use “Generate” in Render |
| `DATABASE_URL` | Paste the **Internal Database URL** from step 1 |

Save.

### 4. Migrations (Free tier: no Shell, no Pre-deploy)

The **Start Command** above runs `db:migrate` before starting Puma, so migrations run on every deploy with no extra step. On **Free** tier, Shell and Pre-deploy command are not available — this start command is the way to run migrations.

On **paid** plans you can instead set **Pre-deploy command** in Settings to `bundle exec rails db:migrate` and use a start command of just `bundle exec puma -C config/puma.rb` if you prefer.

### 5. Deploy

Click **Create Web Service** (or **Save** then **Manual Deploy**). Wait for the build to finish. Open the service URL; you should see the NCG Blog app.

---

## Option B: Deploy with the blueprint (render.yaml)

1. In Render, click **New +** → **Blueprint**
2. Connect the repo that contains this project and select it
3. Render will read `render.yaml` and create:
   - A PostgreSQL database
   - A Web Service with the correct **Build Command** and **Start Command**
4. Migrations run automatically via the Start Command (no Shell or Pre-deploy needed on Free tier).

---

## If the build still fails

1. Open your Web Service on Render → **Logs** tab.
2. Check the **Build logs** (not runtime logs). The error message will be near the bottom.
3. Make sure:
   - **Build Command** is exactly: `bundle install` (no `assets:precompile`).
   - **Start Command** is exactly: `bundle exec rails db:migrate && bundle exec puma -C config/puma.rb`.
   - `DATABASE_URL` is set (Internal Database URL from your PostgreSQL service).
   - `SECRET_KEY_BASE` is set (or generated).

If you paste the **exact** build error from the logs, you can get step-by-step fixes for that error.

---

## "Build successful" but deployment shows Failed

The build only installs gems. The **deploy** fails when Render tries to **start** the app (or run the release command). You need to look at the **right logs**.

### 1. Find the actual error

1. Open your Web Service on Render → **Logs**.
2. Switch to **Deploy logs** or the log stream that shows output **after** "Build successful".
3. Look for the **first error** after the build (e.g. `rails aborted`, `PG::ConnectionBad`, `ArgumentError`, or a stack trace). That is why the deploy failed.

### 2. Common causes and fixes

| If you see… | Fix |
|-------------|-----|
| **DATABASE_URL** / **connection** / **PG::ConnectionBad** | In **Environment**, add `DATABASE_URL` and set it to your PostgreSQL service’s **Internal Database URL**. |
| **SECRET_KEY_BASE** / **ArgumentError** | In **Environment**, add `SECRET_KEY_BASE` (use “Generate” or run `bin/rails secret` locally and paste). |
| **relation "schema_migrations" does not exist** / **table doesn't exist** | Use the **Start Command** that runs migrations first: `bundle exec rails db:migrate && bundle exec puma -C config/puma.rb` (see step 2). Save and redeploy. |
| **Pre-deploy command failed** | Check that `DATABASE_URL` is set and correct; then redeploy so the pre-deploy command runs again. |

### 3. Free tier: no Shell, no Pre-deploy

On **Free** tier, Shell and Pre-deploy command are not available. Use the **Start Command** that runs migrations before Puma: `bundle exec rails db:migrate && bundle exec puma -C config/puma.rb`. On **paid** plans you can use Pre-deploy command in Settings instead if you prefer.

After fixing env vars and/or updating the start command, click **Manual Deploy** and watch the deploy logs to confirm the error is gone.
