# User Documentation

## What This Stack Provides

This project provides a complete WordPress website stack made of three services:

- NGINX serves the website over HTTPS and forwards PHP requests to WordPress.
- WordPress runs the website and provides the administration interface.
- MariaDB stores the WordPress database and user content.

Only NGINX is exposed to the host machine. WordPress and MariaDB stay inside the internal Docker network.

## Start and Stop the Project

Before starting the stack, the data directories are created with:

```bash
make setup
```

Start the project with one of these commands:

```bash
make up
```

or:

```bash
make all
```

Stop the containers without deleting them:

```bash
make stop
```

Remove the containers and network:

```bash
make down
```

## Access the Website and Administration Panel

The website is available at:

```text
https://<DOMAIN_NAME>
```

The WordPress administration panel is available at:

```text
https://<DOMAIN_NAME>/wp-admin
```

The domain name is defined in `srcs/.env`. The project expects that domain to resolve to `127.0.0.1` on the machine where the stack runs.

## Credentials

Credentials are defined in `srcs/.env` and used during the first WordPress and MariaDB startup. The main values are:

- WordPress administrator username and password
- WordPress regular user username, email, and password
- MariaDB database name, user, and passwords

Do not commit `srcs/.env` to version control.

If you need to change credentials, update the environment file and rebuild or restart the stack as needed.

## Access the Database

You can connect to MariaDB from the host by running a client inside the database container:

```bash
docker exec -it mariadb /bin/bash
```
mysql -u your_user -p db_name

After entering the mysql password from `srcs/.env`, you can use standard SQL commands such as:
```sql

SHOW TABLES;

SELECT * FROM wp_users;
```

## Check That Services Are Running Correctly

Use these commands to verify the stack:

```bash
make ps
```

```bash
make logs
```

You can also check the HTTPS endpoint with a browser or with:

```bash
curl -k -I https://<DOMAIN_NAME>
```
Verify change of where WordPress port is listening
``` 
docker compose -f srcs/docker-compose.yml --env-file ./srcs/.env exec wordpress sh -c "grep -R \"listen\\s*=\\s*\" /etc 2>/dev/null || true"

```

If the project was started successfully, the NGINX container should be running, WordPress should be reachable through HTTPS, and the WordPress admin page should load with the credentials from `srcs/.env`.