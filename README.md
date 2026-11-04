# Laravel Docker Boilerplate

Dockerized Laravel 13 boilerplate for local development: spin up a new project with `php artisan serve` without installing PHP or Composer on the host.

## Requirements

- Docker
- Docker Compose v2

That's it: PHP, Composer and every other dependency live inside the container.

## Stack

- Laravel 13
- PHP 8.3+
- PHP built-in server via `php artisan serve` (no Nginx, no PHP-FPM)

## Getting started

### 1. Create your project

Click **Use this template** on GitHub, or clone the repository:

```bash
git clone https://github.com/mattiaferraioli00/laravel-docker-boilerplate.git my-app
cd my-app
```

### 2. Configure the environment

```bash
cp .env.example .env
```

### 3. Build the image and install dependencies

```bash
docker compose build
docker compose run --rm app composer install
docker compose run --rm app php artisan key:generate
```

### 4. Start the app

```bash
docker compose up -d
docker compose exec app php artisan migrate
```

The app is now available at [http://localhost:8000](http://localhost:8000).

## Common commands

| Command | Description |
|---|---|
| `docker compose exec app php artisan <command>` | Run an Artisan command |
| `docker compose exec app composer <command>` | Run a Composer command |
| `docker compose exec app php artisan test` | Run the test suite |
| `docker compose logs -f app` | Follow the application logs |
| `docker compose down` | Stop and remove the containers |

## Notes

- `php artisan serve` is a **development server**: do not use this setup in production.
- Inside the container the server listens on `0.0.0.0`, so it is reachable from the host on the mapped port.
- The built-in server handles one request at a time by default. Set `PHP_CLI_SERVER_WORKERS` (e.g. `4`) in the container environment to serve concurrent requests.

## License

Released under the [MIT License](LICENSE).
