# Developer Documentation

## Prerequisites

To work on this project from a clean machine, install:

- Docker
- Docker Compose
- Make

You also need a domain name that resolves to `127.0.0.1` on the host machine. The project is configured for the 42-style domain name stored in `DOMAIN_NAME`.

## Required Configuration Files

The stack expects an environment file at `srcs/.env`. It provides the values used by Docker Compose, the startup scripts, WordPress, and MariaDB.

Typical variables include:

- `DOMAIN_NAME`
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_PORT`
- `WP_ADMIN_USER`
- `WP_ADMIN_PASSWORD`
- `WP_ADMIN_EMAIL`
- `WP_USER`
- `WP_USER_EMAIL`
- `WP_USER_PASSWORD`
- `SITE_TITLE`

The persistent storage path used by the Makefile is `~/data`, and the compose file maps the service data to directories under that location.

## Build and Launch

Create the host directories used for persistence:

```bash
make setup
```

Build and launch the stack:

```bash
make up
```

or build and launch in one step:

```bash
make all
```

Useful additional targets:

```bash
make build
make stop
make down
make clean
make fclean
make re
make logs
make ps
make precheck
```

`make precheck` is useful before launching because it verifies Docker, the compose file, the environment file values, and the local domain resolution.

## Container and Volume Management

The project uses Docker Compose with three services:

- `nginx`
- `wordpress`
- `mariadb`

The stack uses a dedicated bridge network named `inception`.

Persistence is handled through host-backed storage:

- MariaDB data is stored under `~/data/mariadb`
- WordPress files are stored under `~/data/wordpress`

If you need to inspect the running containers directly, use standard Docker Compose commands from the project root:

```bash
docker compose -f srcs/docker-compose.yml --env-file ./srcs/.env ps
docker compose -f srcs/docker-compose.yml --env-file ./srcs/.env logs -f
docker compose -f srcs/docker-compose.yml --env-file ./srcs/.env stop
docker compose -f srcs/docker-compose.yml --env-file ./srcs/.env down
```

## Where Data Is Stored

The data that must survive container recreation is stored on the host, not inside the containers themselves.

MariaDB writes its database files into the bind-mounted directory mapped to `/var/lib/mysql` inside the container. WordPress stores its site files in the bind-mounted directory mapped to `/var/www/html`.

Because of this layout, removing the containers does not remove the database or the WordPress files unless you also remove the host data directory or run the full cleanup target.

## Project Flow

The startup flow is:

1. NGINX builds its TLS certificate and serves HTTPS on port 443.
2. MariaDB initializes the database directory, creates the database and users, then runs in the foreground.
3. WordPress waits for MariaDB, downloads and configures WordPress if needed, then starts PHP-FPM on port 9000.
4. NGINX proxies PHP requests to the WordPress container over the internal Docker network.

This structure keeps the services separated, reproducible, and easy to rebuild from scratch.

## Directory Structure

The directory structure required for Inception is not arbitrary; it represents industry-standard DevOps blueprints tailored specifically to fulfill strict system administration.

1. The Isolation Principle: Separation of Concerns (SoC)

In the required structure, every service gets its own distinct subdirectory inside srcs/requirements/:

```
srcs/requirements/
├── mariadb/
├── nginx/
└── wordpress/
```

Why it matters: This enforces strict separation of concerns. If a developer needs to update the TLS certificate configurations, they touch only the nginx folder. If they need to change a database setting, they focus only on mariadb. It prevents configuration bleed where one mistake crashes an unrelated service.

2. Immutability of Images vs. Variability of Configurations

Inside each component folder (like mariadb/), the architecture splits into a conf/ directory and a tools/ directory:

```
requirements/mariadb/
├── Dockerfile
├── conf/
│   └── default.conf
└── tools/
    └── init-mariadb.sh
```

This separates static configurations from dynamic runtime execution.

The conf/ files dictate how the program behaves as a system daemon (e.g., binding to 0.0.0.0 or listening on port 3306).

The tools/ files house runtime operational scripts (like bootstrapping database users securely). This structure makes building, debugging, and maintaining the container highly modular.

3. Protecting Secrets and Contextual Boundaries

The docker-compose.yml and the .env file are placed side-by-side at the root of the application stack inside the srcs/ directory.

Why it matters: Docker Compose reads environment variables from a .env file located in the same directory where the command is executed. Keeping srcs/docker-compose.yml and srcs/.env in the exact same directory ensures that Compose can inherently inject those credentials (MYSQL_PASSWORD, WP_ADMIN_PASSWORD) directly into the containers at runtime, without needing to hardcode them in your Git history.

4. Global Orchestration Layer vs. Local Implementation

The Makefile sits completely outside of the srcs/ directory at the root of the repository:

```
Inception/
├── Makefile
└── srcs/
```

This establishes a strict hierarchy of control. The root directory serves as the Control Panel for the evaluator. The evaluator doesn't need to navigate through deep directory levels or understand the micro-configurations of your NGINX server. They stay at the root, run make, and the Makefile acts as the overarching manager that reaches down into srcs/ to spin up the infrastructure.

5. Why Host Folders (like /home/login/data) Must Exist Independently

The project requires that data persist in a dedicated directory on the host machine. By defining volume configurations in docker-compose.yml that target these paths, you separate the infrastructure lifecycle from the data lifecycle.

If a container crashes, burns, or is cleanly removed by a docker compose down, your data is completely unaffected because it resides safely up in the host layer.

In short, this layout forces you to practice Clean Architecture in systems engineering—ensuring your code is reproducible, modular, securely isolated, and easily maintainable by an operations team.