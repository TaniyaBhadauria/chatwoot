This is a custom setup guide created to help new developers install and run Chatwoot locally, with detailed steps, commands, and troubleshooting tips specific to this fork.  For the official project documentation, refer to the main **[README.md.](https://github.com/chatwoot/chatwoot/blob/develop/README.md)**

---
### Prerequisites

To set up and run this project locally, ensure the following tools and environment are in place:

#### ✅ Recommended Operating System

* **Ubuntu 20.04+** (or later)
* **WSL2** on Windows (Windows Subsystem for Linux)

#### ✅ Essential Tools & Dependencies

| Tool                      | Purpose                     |
|---------------------------| --------------------------- |
| **Ruby** (v3.4.4)         | Backend runtime             |
| **rbenv**                 | Ruby version manager        |
| **bundler**               | Ruby package manager        |
| **Node.js** (via `pnpm`  23.x (newer)) | Frontend runtime            |
| **Yarn** or **pnpm**      | JavaScript package managers |
| **PostgreSQL**            | Primary database            |
| **Redis**                 | In-memory data store        |
| **Overmind**              | Procfile process manager    |
---

## Step 1: Install System Dependencies

Open a terminal and run the following commands to install essential build tools, libraries, and runtime environments.

### Update System Packages

```bash
   sudo apt update && sudo apt upgrade -y
```

### Install Essential Tools & Libraries

```bash
  sudo apt install -y \
  git curl gnupg build-essential \
  libssl-dev libreadline-dev zlib1g-dev libpq-dev \
  libyaml-dev libffi-dev libgdbm-dev libncurses5-dev \
  libgmp-dev redis postgresql postgresql-contrib
```

---

## Install Ruby (3.4.4) with `rbenv`

### 1. Install `rbenv`

```bash
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
    source ~/.bashrc
```

### 2. Install `ruby-build`

```bash
   git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

### 3. Install Ruby and Set Global Version

```bash
   rbenv install 3.4.4
   rbenv global 3.4.4
```

**Confirm Ruby installation:**

```bash
   ruby -v  # Should return: ruby 3.4.4
```

### 4. Install Bundler

```bash
   gem install bundler -v 2.5.16
```

---

### 5. Install pnpm (JavaScript Package Manager)

```bash
   npm install -g pnpm
```

> **Note:** You may need to install Node.js first using your preferred method (e.g., `nvm` or system package).


#### ⚠️ Troubleshooting & Tips : Helpful tips and solutions to common setup issues:

---

> 💡 **Tip: Use a version manager like** `rbenv` **for Ruby**
> This ensures consistent Ruby versions across environments and prevents conflicts with system-installed Ruby.
---

> ⚠️ **Issue: "Your Ruby version is X, but Gemfile requires Y"**
> You're likely not using Ruby `3.4.4`. Run the following to install and switch:

```bash
   rbenv install 3.4.4
   rbenv global 3.4.4
```
Then confirm with:

```bash
   ruby -v  # Should return: ruby 3.4.4
```

---

> ⚠️ **Issue: “Don't run Bundler as root”**
> Running `bundle install` with `sudo` can break file permissions. Always use:

```bash
   bundle install
```
⚠️ Issue: Ruby build failure due to missing libffi or psych dependencies
If rbenv install fails during Ruby compilation, you may be missing required system libraries. Fix it by installing them:
```bash
   sudo apt update && sudo apt install -y libffi-dev libyaml-dev build-essential libssl-dev zlib1g-dev libreadline-de
```

---

## Step 2: Install Project Dependencies

### Install Ruby Gems

```bash
   bundle install
```

### Install JavaScript Packages

```bash
   pnpm install
```
---
## Step 3: Run application
### 1. Ensure Overmind is installed if not follow the below steps:
Download the gzipped Overmind binary
```bash
   curl -L https://github.com/DarthSim/overmind/releases/download/v2.1.0/overmind-v2.1.0-linux-amd64.gz -o overmind.gz
```
 Unzip it to get the actual binary
```bash
   gunzip overmind.gz
```
Move it to a directory in your PATH (you’ll be prompted for your password)
```bash
   sudo mv overmind /usr/local/bin
```
Make it executable
```bash
   sudo chmod +x /usr/local/bin/overmind
```

Verify it's working
```bash
   overmind version
```
### 2. You must create a .env file in the root of the Chatwoot project directory.
Chatwoot provides a sample environment file. You can create the .env file by copying the example:
```bash
   cp .env.example .env
```

### 3. Install Redis (Redis 6.2.0 or newer)
Install Redis (v6.2+):
```bash
  sudo add-apt-repository ppa:redislabs/redis
  sudo apt update
  sudo apt install redis-server
```
Check version:

```bash
  redis-server --version
```

Start Redis:

```bash
  sudo service redis-server start
```
Update the Redis URL in the .env file:
```
REDIS_URL=redis://localhost:6379
```
Verify it's running:

```bash
  redis-cli ping  # Should return PONG
```

> 💡 **Tip:** Ensure Redis is running in the background before starting Chatwoot. Use `sudo service redis-server status` to check.
---

> ⚠️ **Troubleshooting Tip: Redis service is masked**
>
> If you see this error when starting Redis:
>
> ```
> Failed to start redis-server.service: Unit redis-server.service is masked.
> ```
>
> It means the service is disabled at the system level.
>
> ✅ **Fix it with:**
>
> ```bash
> sudo systemctl unmask redis-server
> sudo systemctl enable redis-server
> sudo systemctl start redis-server
> ```

---

### 4. Set Up PostgreSQL

Make sure PostgreSQL is running:

```bash
   sudo service postgresql start
  # or
   sudo systemctl start postgresql
```

> 💡 **Tip:** To check access, run:
>
> ```bash
> psql -U postgres
> ```
>
> If it fails:
>
> * The `postgres` user may not exist
> * The password may be wrong

🔧 **Reset the password if needed:**

```bash
sudo -u postgres psql
\password chatwoot123
```

📦 **Create or set up the database:**

```bash
bin/rails db:setup
# or manually:
bin/rails db:create db:migrate
```
---

### Verify PostgreSQL Connection
You can test your connection with:

```bash
psql -U postgres -h localhost -p 5433 -d chatwoot
```

---

### 5. Update Environment Variables

In your `.env` file, add or confirm the following:

```env
POSTGRES_DATABASE=chatwoot
POSTGRES_HOST=localhost
POSTGRES_PORT=5433
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=chatwoot123
RAILS_ENV=development
```

---

### 6. Update `config/database.yml`

Ensure the `default` and `development` sections match your environment:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  host: <%= ENV.fetch('POSTGRES_HOST', 'localhost') %>
  port: <%= ENV.fetch('POSTGRES_PORT', '5433') %>
  pool: <%= Sidekiq.server? ? ENV.fetch('SIDEKIQ_CONCURRENCY', 10) : ENV.fetch('RAILS_MAX_THREADS', 5) %>
  reaping_frequency: <%= ENV.fetch('DB_POOL_REAPING_FREQUENCY', 30) %>
  variables:
    statement_timeout: <%= ENV["POSTGRES_STATEMENT_TIMEOUT"] || "14s" %>

development:
  <<: *default
  database: "<%= ENV.fetch('POSTGRES_DATABASE', 'chatwoot') %>"
  username: "<%= ENV.fetch('POSTGRES_USERNAME', 'postgres') %>"
  password: "<%= ENV.fetch('POSTGRES_PASSWORD', 'chatwoot123') %>"
```

> 💡 **Tip:** Ensure your PostgreSQL server is running on the specified port (5433) and accepting local connections. Adjust the port if you're using the default (5432).

### 7. Run the App

```bash
   pnpm dev
```
Access the Chatwoot UI
   Open your browser and navigate to: **http://127.0.0.1:3000/app/login**
---
---
### ⚠️ Troubleshooting Tips
#### 🔐 Enabling Signup Route

To enable the **signup page** in the Chatwoot application, make the following changes:

**Update the route configuration:**

In your `routes.js` file, set `requireSignupEnabled` to `false` for the `/auth/signup` path:

```js
{
  path: frontendURL('auth/signup'),
  name: 'auth_signup',
  component: Signup,
  meta: { requireSignupEnabled: false }, // Enables the signup page
}
```
---

###  **Migrations Are Pending**

If you see a message about pending migrations, run the following:
```bash
  bin/rails db:migrate
```
---

###  **Error: `vector.control` file missing**

If you get this error:

```
PG::UndefinedFile: ERROR:  could not open extension control file "/usr/share/postgresql/14/extension/vector.control": No such file or directory
```

It means your database is missing the `vector` extension (likely from [`pgvector`](https://github.com/pgvector/pgvector)).

---

### Fix: Install `pgvector` (PostgreSQL 14)

1. **Install PostgreSQL 14 development tools:**

```bash
sudo apt-get install postgresql-server-dev-14
```

2. **Clone and install pgvector:**

```bash
  git clone https://github.com/pgvector/pgvector.git
cd pgvector
make
sudo make install
```

3. **Create the extension in your database:**

```bash
  psql -U postgres -d chatwoot -c "CREATE EXTENSION vector;"
```

Replace `postgres` and `chatwoot` with your actual username and DB name.

---

### 🚀 After pgvector installation

Run the migration again:

```bash
bin/rails db:migrate
```
---

## Chatwoot Bot Integration
Easily add the **Chatwoot** support bot to your website.

### 1. Log in or create a new account.

### 2. Create a Website Inbox

* Navigate to *Inboxes > Add Inbox*
* Select *Website* as the channel type
* Fill in:
  * *Website Name* (e.g., MySite Support)
  * *Domain* (e.g., www.mysite.com)
  * *Tagline* (a short welcome message or description)

### 3. Assign Agents

* After creating the inbox, Chatwoot will allow you to select team members (agents) from a dropdown menu.
* Choose who should be assigned to respond to chats on this inbox.

### 4. Copy the Installation Script

* After completing the above steps, Chatwoot generates a script tag (code snippet).
* It looks something like this:

Example:

```html
<script>
  (function(d,t) {
    var BASE_URL = "https://your-chatwoot-domain.com";
    var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
    g.src= BASE_URL + "/packs/js/sdk.js";
    g.defer = true;
    g.async = true;
    s.parentNode.insertBefore(g,s);
    g.onload = function(){
      window.chatwootSDK.run({
        websiteToken: 'your-generated-website-token',
        baseUrl: BASE_URL
      });
    }
  })(document,"script");
</script>
```
---

### 5. Run Asset Precompilation

After creating the website pack, run the following to compile the necessary assets:

```bash
   bundle exec rails assets:precompile RAILS_ENV=production
```

> This ensures your JavaScript, CSS, and other frontend assets are correctly compiled.

---

### Embedding the Chatwoot Widget

Copy and paste this snippet into the `<head>` or end of `<body>` section of your website’s HTML.

---

### Testing Guide

Use the following commands to run and debug tests in the Chatwoot codebase.
To run all JavaScript test cases:

```bash
   pnpm test
```
To run **all** Ruby RSpec tests:
```bash
  bundle exec rspec
```
