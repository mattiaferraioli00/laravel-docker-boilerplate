# Troubleshooting

[← Back to the README](../README.md)

Common problems and how to fix them. Look for the error you see.

## `sail: command not found`

Sail is not installed system-wide: run it as `./sail`, or add the alias from the [Quick start](../README.md#-quick-start). Do not install the `bsdgames` package your system suggests: its `sail` is a game.

## `service "laravel.test" is not running`

`APP_SERVICE=app` is missing from `.env`, so Sail looks for its default service name. Add it.

## `Sail is not running`

The command runs inside a container and the containers are stopped. Start them with `./sail up -d --wait`.

## `Bind for 127.0.0.1:8080 failed: port is already allocated`

Another container or program uses that port, often a second project started from this template. Stop it, or change the port in `.env` (see [Run several projects at the same time](configuration.md#run-several-projects-at-the-same-time)).

## The app container is `unhealthy` or `--wait` never ends

Look at the logs: usually `composer install` failed (network, incompatible lock file, missing extension).

```bash
./sail logs app
```

## `getaddrinfo for mysql failed`

The app cannot resolve the `mysql` service: the MySQL container is stopped or detached from the network. Check with `./sail ps`, then recreate everything:

```bash
./sail down
./sail up -d --wait
```

## `getaddrinfo for valkey failed` or `Connection refused` on cache, queue or mail

The app still points to a service that is off. Either add the service back to `COMPOSE_PROFILES`, or switch the Laravel setting that uses it: `CACHE_STORE=database` and `QUEUE_CONNECTION=database` for Valkey, `MAIL_MAILER=log` for Mailpit. See [Turn services on and off](configuration.md#turn-services-on-and-off).

## A service I turned off is still running

`COMPOSE_PROFILES` was changed while the containers were up, so Compose no longer manages that service. Enable its profile just for this command and remove the leftover container:

```bash
./sail --profile mailpit rm -sf mailpit
```

## The `testing` database does not exist

The script that creates it runs only on the first initialization of the MySQL volume. Recreate the volume (deletes the data):

```bash
./sail down -v
./sail up -d --wait
```

Or create it by hand:

```bash
./sail exec mysql mysql -u root -ppassword -e "CREATE DATABASE IF NOT EXISTS testing; GRANT ALL ON \`testing%\`.* TO 'sail'@'%';"
```

## Files owned by root in the project

Something ran as root: `sudo`, or `docker compose exec` without `-u sail`. Give the files back to your user:

```bash
sudo chown -R "$(id -u):$(id -g)" .
```

## Valkey warns about `Memory overcommit`

It is a setting of your machine's kernel and only matters for background saves under low memory. It is safe to ignore locally. To silence it:

```bash
sudo sysctl vm.overcommit_memory=1
```

## My IDE underlines the healthchecks in `compose.yaml`

Some IDEs ship an outdated Compose schema. Docker Compose is the reference:

```bash
./sail config --quiet
```

No output means the file is valid.

---

[← Back to the README](../README.md) · [How it works](how-it-works.md) · [Usage](usage.md) · [Configuration](configuration.md) · [Customizing and updating Sail](maintenance.md)
