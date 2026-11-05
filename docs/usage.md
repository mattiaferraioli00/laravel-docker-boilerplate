# Usage

[← Back to the README](../README.md)

Everyday work with the boilerplate: commands, frontend, database, cache and queues, tests, debugging, and plain Docker Compose.

## Daily commands

| Command | What it does |
|---|---|
| `./sail up -d --wait` | Start everything in the background and wait until it is healthy |
| `./sail stop` | Stop the containers, keep them |
| `./sail down` | Stop and remove the containers (data is kept in volumes) |
| `./sail down -v` | Same, **and delete the database and Valkey data** |
| `./sail ps` | Containers, health and ports |
| `./sail logs -f app` | Follow the logs of a service |
| `./sail artisan <command>` | Run an Artisan command |
| `./sail tinker` | Open Tinker |
| `./sail composer <command>` | Run Composer |
| `./sail test` | Run the test suite |
| `./sail pint` | Fix the code style |
| `./sail npm <command>` | Run npm (also `npx`, `pnpm`, `yarn`, `bun`) |
| `./sail shell` | Open a shell in the app container as your user |
| `./sail root-shell` | Open a root shell in the app container |
| `./sail mysql` | Open the MySQL client on the application database |
| `./sail valkey` | Open `valkey-cli` (when Valkey is on) |
| `./sail port mysql 3306` | Show the host port of a service |

> [!NOTE]
> Commands that run inside a container (`artisan`, `composer`, `tinker`, `npm`, …) need the containers to be running. If they are not, Sail answers *"Sail is not running"*: start them with `./sail up -d --wait`.

## Frontend with Vite

```bash
./sail npm install
./sail npm run dev
```

The Laravel Vite plugin detects Sail: the dev server listens inside the container and your browser loads the assets from `localhost:5173` (`VITE_PORT`). For a production build:

```bash
./sail npm run build
```

To pin the version of pnpm, Yarn or npm for the whole team, set the `packageManager` field in `package.json`: Corepack is enabled in the image.

## Database

| Setting | Value |
|---|---|
| Host from the app | `mysql` (port `3306`) |
| Host from your machine | `127.0.0.1`, port from `./sail port mysql 3306` |
| Database | `laravel` (and `testing` for the tests) |
| User / password | `sail` / `password` |
| Root password | same as `DB_PASSWORD` |

**Connecting with a database client** (DBeaver, TablePlus, PhpStorm, …): use `127.0.0.1` and the port shown by `./sail port mysql 3306`. The port is random and may change when the container is recreated; for a stable one, set `FORWARD_DB_PORT` (for example `3307`) in `.env` and run `./sail up -d`.

**The `testing` database** is created by `docker/mysql/create-testing-database.sh` the first time the MySQL volume is initialized. If your volume existed before, the script did not run: see [Troubleshooting](troubleshooting.md#the-testing-database-does-not-exist).

**Starting from scratch** deletes all data:

```bash
./sail down -v
./sail up -d --wait
./sail artisan migrate
```

## Cache, queues and mail

- **Cache and queues** use Valkey through Laravel's `redis` driver (`CACHE_STORE=redis`, `QUEUE_CONNECTION=redis`). The `phpredis` extension is already in the image. Without Valkey, switch both to `database` (see [Turn services on and off](configuration.md#turn-services-on-and-off)).
- **Queued jobs need a worker.** There is no worker container: jobs wait in Valkey until you run one.

  ```bash
  ./sail artisan queue:work
  ```

- **Sessions** are stored in the database (`SESSION_DRIVER=database`).
- **Mail** goes to Mailpit over SMTP. Nothing leaves your machine: open http://localhost:8025 to read every email the app sends. Without Mailpit, set `MAIL_MAILER=log` and read the emails in `storage/logs/laravel.log`.

## Testing

```bash
./sail test
```

Tests run on the MySQL `testing` database (set in `phpunit.xml`), so your development data is never touched. Use `--filter` to run a single test:

```bash
./sail test --filter=ExampleTest
```

## Debugging with Xdebug

Xdebug is installed but off by default.

1. Enable it in `.env`:

   ```dotenv
   SAIL_XDEBUG_MODE=develop,debug
   ```

2. Recreate the app container: `./sail up -d --wait`.
3. In your IDE, listen on port **9003** and map the project folder to **`/var/www/html`**.
4. Start a session:
    - **Artisan commands:** `./sail debug <command>`, e.g. `./sail debug migrate`.
    - **Browser requests:** use an Xdebug browser extension, or add `XDEBUG_TRIGGER=1` to the query string.

The container reaches your IDE through `host.docker.internal`, which is mapped to your machine in `compose.yaml` (on Linux too).

## Using Docker Compose without Sail

Sail is optional: `compose.yaml` works with plain `docker compose`. Two things to know:

- `WWWUSER` and `WWWGROUP` must be in `.env`. The setup script writes them.
- `docker compose exec` runs as root by default. Always add `-u sail`, or the files you create will belong to root.

```bash
docker compose up -d --wait
docker compose exec -u sail app php artisan migrate
docker compose exec -u sail app composer require laravel/sanctum
docker compose logs -f app
```

---

[← Back to the README](../README.md) · [How it works](how-it-works.md) · [Configuration](configuration.md) · [Customizing and updating Sail](maintenance.md) · [Troubleshooting](troubleshooting.md)
