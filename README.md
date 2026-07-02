*This project has been created as part of the 42 curriculum by mipinhei.*

# Inception

## Description

Inception is a Docker-based web stack that deploys a secure WordPress website backed by MariaDB and served through NGINX with HTTPS.

The goal of the project is to build and understand a small but complete infrastructure using containers, isolated services, persistent storage, and automated startup scripts. The stack is intentionally split into three services:

- NGINX handles HTTPS termination and reverse proxying.
- WordPress runs on PHP-FPM and provides the website and administration interface.
- MariaDB stores the WordPress database and user data.

### Project Description

This repository contains the full source needed to build the stack with Docker Compose:

- `Makefile` for setup, build, run, and cleanup targets.
- `srcs/docker-compose.yml` to define the service topology, network, and persistent storage.
- Custom Dockerfiles for NGINX, WordPress, and MariaDB.
- Custom configuration files for NGINX, PHP-FPM, and MariaDB.
- Startup scripts that initialize the database and install WordPress automatically.

The main design choices are:

- Each major service runs in its own container so the stack stays modular and easy to rebuild.
- NGINX is the only container exposed to the host, which keeps the database and PHP-FPM isolated inside the Docker network.
- WordPress installation is automated so the stack can be recreated from scratch with one command.
- Data is persisted on the host under the user home directory so containers can be removed and recreated without losing the database or website files.

#### Virtual Machines vs Docker

Virtual machines include a full guest operating system, which gives strong isolation but uses more disk, RAM, and startup time. Docker containers share the host kernel, so they are lighter, faster to start, and easier to rebuild for this project. For a web stack like Inception, Docker is the better fit because the goal is service isolation and reproducibility rather than full OS virtualization.

#### Secrets vs Environment Variables

Environment variables are used here to configure the stack because they are simple to manage in a school project and integrate naturally with Docker Compose. In a production setup, secrets would be preferred for sensitive values such as passwords because they are handled more carefully than plain environment variables. Here, environment variables are acceptable for the project workflow, but they still need to be protected and never committed to the repository.

#### Docker Network vs Host Network

This project uses a dedicated bridge network named `inception`. That keeps service-to-service traffic inside the stack and lets containers reach each other by service name. Host networking would remove that isolation and would expose the containers directly on the host network, which is unnecessary here because only NGINX needs a public port.

#### Docker Volumes vs Bind Mounts

The stack uses persistent storage mapped to directories on the host, which behaves like bind-mounted storage. This makes the data easy to inspect, back up, and preserve between container rebuilds. A Docker-managed volume is more opaque and more automated, while a bind mount is more transparent and convenient when you want to clearly see where the data lives. For Inception, the host-backed storage makes the persistence requirement explicit and easy to verify.

## Instructions

### Prerequisites

- Docker
- Docker Compose
- Make
- A valid domain name that resolves to `127.0.0.1` on the machine where you run the stack

### Configuration

Before starting the project, create the environment file expected by Compose at `srcs/.env` and fill in the required variables:

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

The persistent data directories are created under `~/data` by the setup target.

### Build and Run

1. Create the persistence directories:

   ```bash
   make setup
   ```

2. Start the full stack:

   ```bash
   make up
   ```

   or:

   ```bash
   make all
   ```

3. Open the website in a browser:

   ```text
   https://<DOMAIN_NAME>
   ```

4. Use the WordPress administration panel at:

   ```text
   https://<DOMAIN_NAME>/wp-admin
   ```

### Useful Make Targets

- `make build` builds the images without starting the services.
- `make stop` stops the containers without removing them.
- `make down` stops and removes containers and the Docker network.
- `make clean` removes containers and project images.
- `make fclean` performs a full cleanup, including volumes and persistent data.
- `make re` performs a full cleanup and then rebuilds the stack.
- `make logs` follows the container logs.
- `make ps` lists the running containers.
- `make precheck` validates Docker availability, the compose file, environment variables, and local domain resolution.

## Resources

Useful references for this project:

- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- NGINX documentation: https://nginx.org/en/docs/
- WordPress documentation: https://wordpress.org/documentation/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- WP-CLI documentation: https://developer.wordpress.org/cli/commands/
