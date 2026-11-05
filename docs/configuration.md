# Configuration

[← Back to the README](../README.md)

Every setting of the boilerplate lives in `.env`. This page explains each variable and shows the most common changes.

All settings live in `.env`. The file is split in two parts that behave differently:

| Part | An empty value means |
|---|---|
| **Laravel** (top of the file) | An empty string. To use Laravel's config default, comment the line out instead. |
| **Docker / Sail** (bottom of the file) | The default written in `compose.yaml` (`${VAR:-default}`). Exception: an empty `COMPOSE_PROFILES` starts no optional service |

## Docker / Sail variables

| Variable | Default | Rebuild | Description |
|---|---|:---:|---|
| `APP_SERVICE` | `app` | | Name of the application service. Required: Sail would look for `laravel.test` |
| `APP_BIND_ADDRESS` | `127.0.0.1` | | Interface the ports are bound to |
| `APP_PORT` | `8080` | | Host port of the application. Keep it in sync with `APP_URL` |
| `VITE_PORT` | `5173` | | Host port of the Vite dev server |
| `FORWARD_DB_PORT` | random | | Host port of MySQL |
| `FORWARD_VALKEY_PORT` | random | | Host port of Valkey |
| `FORWARD_MAILPIT_DASHBOARD_PORT` | `8025` | | Host port of the Mailpit dashboard |
| `WWWUSER` / `WWWGROUP` | your uid / gid | | Written by the setup script, computed by Sail |
| `PHP_VERSION` | `8.5` | ✔ | PHP runtime: `8.3`, `8.4` or `8.5` |
| `NODE_VERSION` | `24` | ✔ | Node.js major version |
| `COMPOSER_VERSION` | latest | ✔ | Exact Composer version, e.g. `2.8.4` |
| `PHP_EXTENSIONS` | none | ✔ | Extra extensions, space separated, e.g. `"gmp apcu"` |
| `COMPOSE_PROFILES` | `valkey,mailpit` | | Optional services to start, comma separated. The app and MySQL always run |
| `MYSQL_VERSION` | `8.4` | | MySQL image tag |
| `VALKEY_VERSION` | `9` | | Valkey image tag (`<version>-alpine`) |
| `MAILPIT_VERSION` | `latest` | | Mailpit image tag |

Variables marked **Rebuild** are build arguments of the app image. After changing one:

```bash
./sail build
./sail up -d --wait
```

The rebuild takes a few minutes, because these values are used by the step that installs PHP, Composer and Node.

## Examples

### Switch to PHP 8.3

```bash
sed -i 's|^PHP_VERSION=.*|PHP_VERSION=8.3|' .env
./sail build
./sail up -d --wait
./sail php -v
```

The Composer platform is pinned to PHP 8.3 in `composer.json` (`config.platform.php`), so `composer.lock` stays installable on every supported runtime.


### Add PHP extensions

Extensions are installed as `php<version>-<name>` packages, so use the package name without the prefix:

```bash
sed -i 's|^PHP_EXTENSIONS=.*|PHP_EXTENSIONS="gmp apcu"|' .env
./sail build
./sail up -d --wait
./sail php -m
```

Many common extensions are already in the image: check `./sail php -m` before adding one.


### Turn services on and off

Valkey and Mailpit are [Compose profiles](https://docs.docker.com/compose/how-tos/profiles/): a service starts only when its name is in `COMPOSE_PROFILES`. The app does not wait for a service that is off.

Stop the containers **before** changing the value, so Compose also removes the service you are turning off:

```bash
./sail down
```

Then edit `.env`. For example, an API without email:

```dotenv
COMPOSE_PROFILES=valkey
MAIL_MAILER=log
```

and start again:

```bash
./sail up -d --wait
./sail ps
```

Laravel does not know which services are running, so update the settings that use the one you turn off:

| Turned off | Change in `.env` | Result |
|---|---|---|
| `valkey` | `CACHE_STORE=database`, `QUEUE_CONNECTION=database` | Cache and jobs use the `cache` and `jobs` tables, created by the default migrations |
| `mailpit` | `MAIL_MAILER=log` | Emails are written to `storage/logs/laravel.log` |

To turn a service back on, add its name to `COMPOSE_PROFILES`, restore the settings and run `./sail up -d --wait`.


### Change the service versions

```bash
sed -i 's|^MYSQL_VERSION=.*|MYSQL_VERSION=8.4|' .env
./sail up -d --wait
```

Services use ready-made images, so no rebuild is needed: Compose pulls the new tag.

**Careful with downgrades:** MySQL cannot go back to an older version on a data folder created by a newer one. Before a downgrade, run `./sail down -v`: it deletes the database.


### Run several projects at the same time

MySQL and Valkey already get a random free port. The app, Vite and Mailpit ports are fixed, so change them in the second project's `.env`:

```dotenv
APP_PORT=8081
APP_URL=http://localhost:8081
VITE_PORT=5174
FORWARD_MAILPIT_DASHBOARD_PORT=8026
```

Each project gets its own containers, network, volumes and image, named after its folder.

---

[← Back to the README](../README.md) · [How it works](how-it-works.md) · [Usage](usage.md) · [Customizing and updating Sail](maintenance.md) · [Troubleshooting](troubleshooting.md)
