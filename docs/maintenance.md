# Customizing and updating Sail

[← Back to the README](../README.md)

Where each kind of change belongs, how to update Laravel Sail without losing the boilerplate's changes, and how the project is organized.

## Where changes go

| Change | Where |
|---|---|
| Versions, ports, extensions | `.env` |
| Services, healthchecks, startup command, build arguments | `compose.yaml` |
| Changes to Sail's Dockerfiles | `scripts/sail/publish.sh` |

**Do not edit the files in `docker/` by hand.** They are Sail's files: the next update overwrites them. Every change to them lives in `scripts/sail/publish.sh`, which re-applies it after each update. Today it adds the `COMPOSER_VERSION` build argument.

## Updating Sail

```bash
./sail composer update laravel/sail
./scripts/sail/publish.sh
git diff docker/ sail
./sail build --no-cache
./sail up -d --wait
```

`publish.sh` re-publishes Sail's Dockerfiles, database scripts and `./sail`, removes what the boilerplate does not use (PHP 8.0–8.2, MariaDB and PostgreSQL scripts) and re-applies the boilerplate changes. If Sail changed its Dockerfile so much that a change cannot be applied, the script stops with an error that says what to update. `compose.yaml` is never touched.

## Adding a service

```bash
./sail artisan sail:add
```

Sail adds the new service to `compose.yaml`, but it looks for the application service under its default name (`laravel.test`). It will warn you that it could not find it: add the new service to `app.depends_on` yourself.

## Project structure

Only the files added or changed by the boilerplate are listed; everything else is a standard Laravel 13 application.

```text
.
├── compose.yaml                 # services, ports, healthchecks, build arguments, startup command
├── sail                         # Sail CLI, committed so it works before composer install
├── .env.example                 # documented settings: Laravel on top, Docker / Sail below
├── docker/
│   ├── 8.3/  8.4/  8.5/          # PHP runtimes: Dockerfile, php.ini, supervisord.conf, start-container
│   └── mysql/
│       └── create-testing-database.sh
├── scripts/sail/
│   ├── setup.sh                 # creates .env with your uid, gid and an application key
│   └── publish.sh               # re-publishes Sail's files and re-applies the boilerplate changes
└── phpunit.xml                  # tests run on the MySQL testing database
```

---

[← Back to the README](../README.md) · [How it works](how-it-works.md) · [Usage](usage.md) · [Configuration](configuration.md) · [Troubleshooting](troubleshooting.md)
