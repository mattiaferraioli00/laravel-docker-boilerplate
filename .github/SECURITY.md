# Security Policy

## Supported versions

Only the latest version on the `main` branch is supported. Projects created from this template do not receive updates automatically: when a security fix lands on `main`, apply it to your project by hand.

## Scope

This boilerplate is meant for **local development only**. Weaknesses that only matter when it is used in production (for example `php artisan serve`, the default database password or the Mailpit dashboard without authentication) are known limits of a development setup, not vulnerabilities.

Vulnerabilities in the software it builds on belong to their own projects: report them to [Laravel](https://github.com/laravel/framework/security/policy), [Laravel Sail](https://github.com/laravel/sail/security/policy), MySQL, Valkey or Mailpit directly.

## Reporting a vulnerability

**Please do not open a public issue.** Use GitHub's private vulnerability reporting instead: open the [Security tab](https://github.com/mattiaferraioli00/laravel-docker-boilerplate/security) of the repository and click **Report a vulnerability**.

Include what is affected, how to reproduce it and what an attacker could do with it. You will get an answer as soon as possible, and the fix will be credited to you unless you prefer otherwise.
