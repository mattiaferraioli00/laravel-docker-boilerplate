# Contributing

Thank you for considering contributing to Laravel Docker Boilerplate! This is an open-source project and every proposal to make it better is welcome: a new configurable option, a clearer explanation in the README, a bug you hit on your machine, or a better way to do something that is already here.

## Reporting a bug or proposing an idea

[Open an issue](https://github.com/mattiaferraioli00/laravel-docker-boilerplate/issues). For a bug, include:

- what you expected and what happened instead;
- the commands you ran and their output (`./sail logs app` is often the most useful);
- your setup: operating system, `docker version` and the relevant lines of your `.env`.

For an idea, describe the problem it solves before the solution: it makes it easier to find the simplest way to get there.

## Opening a pull request

1. Fork the repository and create a branch from `main`.
2. Keep the pull request focused on one change.
3. Explain *what* changes and *why* in the description.
4. Update the README and `.env.example` when the change affects how the boilerplate is used or configured.

## Guidelines

- **Keep it configurable.** New options belong in `.env`, with a sensible default when the value is empty (`${VAR:-default}` in `compose.yaml`), and are documented in `.env.example` and in the README.
- **Leave `docker/` alone.** The files in `docker/` come from Laravel Sail and are overwritten on every Sail update. Changes to them go in `scripts/sail/publish.sh`, which re-applies them after each update.
- **Prefer `compose.yaml`.** Services, healthchecks, build arguments and the startup command are configured there, so they survive Sail updates.
- **Never require PHP, Composer or Node on the host.** Everything runs in Docker, through `./sail`.

## Testing on a fresh clone

Your working folder already has `vendor/`, a `.env`, a built image and initialized volumes, so it hides problems. Before opening a pull request, commit your changes and check that the quick start works from zero:

```bash
git clone <your-fork> /tmp/boilerplate-test
cd /tmp/boilerplate-test
./scripts/sail/setup.sh
./sail up -d --wait
./sail artisan migrate
./sail test
./sail down -v
```

If your change touches the image (`docker/`, build arguments, `PHP_VERSION`, …), remove the test image first so it is really rebuilt:

```bash
docker image rm boilerplate-test-app
```

## Commit messages

Write a short subject in the imperative mood ("Add …", "Fix …", "Make … configurable"), then a list of the changes in the body when there is more than one.

## Code of Conduct

Please be respectful and constructive. By participating in this project you agree to abide by its [Code of Conduct](CODE_OF_CONDUCT.md).
