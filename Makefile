.DEFAULT_GOAL := all

.PHONY: all setup build up stop down clean fclean re logs ps precheck

# =========================
# VARIABLES
# =========================
# For 42 School environment: set to your login (e.g., mipinhei.42.fr)
DOMAIN_NAME ?= mipinhei.42.fr
COMPOSE_FILE = srcs/docker-compose.yml
# FIXED: Changed from hardcoded path to ${HOME}/data for flexibility
# Previously: /home/mipinhei/data
DOCKER_COMPOSE = docker compose -f $(COMPOSE_FILE) --env-file ./srcs/.env
DATA_PATH = ${HOME}/data

# =========================
# SETUP TARGET
# =========================
setup:
	@echo "Creating data directories..."
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@echo "Setup complete"

# =========================
# BUILD TARGETS
# =========================
all: up
	@echo "Building Inception infrastructure..."
	$(DOCKER_COMPOSE) up -d --build
	@echo "Inception started successfully!"
	@echo "Waiting for HTTPS endpoint to be ready..."
	@i=0; \
	until curl -k -I https://127.0.0.1 -H 'Host: $(DOMAIN_NAME)' --max-time 2 >/dev/null 2>&1; do \
		i=$$((i + 1)); \
		if [ $$i -ge 30 ]; then \
			echo "HTTPS endpoint did not become ready in time"; \
			exit 1; \
		fi; \
		sleep 2; \
	done
	curl -k -I https://127.0.0.1 -H 'Host: $(DOMAIN_NAME)' --max-time 10
	@echo "Access: https://$(DOMAIN_NAME)"

build:
	@echo "Building Docker images..."
	$(DOCKER_COMPOSE) build --no-cache

# =========================
# PREFLIGHT TARGETS
# =========================
precheck:
	@echo "Running Inception preflight checks..."
	@command -v docker >/dev/null 2>&1 || { echo "[ERROR] docker is not installed or not in PATH"; exit 1; }
	@docker compose version >/dev/null 2>&1 || { echo "[ERROR] docker compose is not available"; exit 1; }
	@test -f $(COMPOSE_FILE) || { echo "[ERROR] Missing $(COMPOSE_FILE)"; exit 1; }
	@if [ -f ./srcs/.env ]; then \
		set -a; . ./srcs/.env; set +a; \
		check_var() { \
			eval "value=\$$1"; \
			if [ -z "$$value" ]; then \
				echo "[ERROR] $$1 is empty in ./srcs/.env"; \
				exit 1; \
			fi; \
		}; \
		for var in DOMAIN_NAME MYSQL_DATABASE MYSQL_USER MYSQL_PASSWORD MYSQL_ROOT_PASSWORD MYSQL_PORT WP_ADMIN_USER WP_ADMIN_PASSWORD WP_ADMIN_EMAIL WP_USER WP_USER_EMAIL WP_USER_PASSWORD SITE_TITLE; do \
			check_var $$var; \
		done; \
	else \
		echo "[WARN] ./srcs/.env is missing; skipping env value validation"; \
	fi; \
	DOMAIN_CHECK="$${DOMAIN_NAME:-mipinhei.42.fr}"; \
	getent hosts "$$DOMAIN_CHECK" >/dev/null 2>&1 || { echo "[ERROR] $$DOMAIN_CHECK does not resolve on this host"; exit 1; }; \
	getent hosts "$$DOMAIN_CHECK" | grep -Eq '(^127\.0\.0\.1[[:space:]]|^[[:space:]]*127\.0\.0\.1[[:space:]]).*' || { echo "[ERROR] $$DOMAIN_CHECK does not resolve to 127.0.0.1"; exit 1; }; \
	echo "[OK] Preflight checks passed"

up: setup
	@echo "Starting containers..."
	$(DOCKER_COMPOSE) up -d --build
	@echo "Containers started"

# =========================
# STOP TARGETS
# =========================
stop:
	@echo "Stopping containers gracefully..."
	$(DOCKER_COMPOSE) stop
	@echo "Containers stopped"

down:
	@echo "Stopping and removing containers, networks..."
	$(DOCKER_COMPOSE) down
	@echo "Containers removed"

# =========================
# CLEAN TARGETS
# =========================
clean: down
	@echo "Removing Docker images..."
	@docker rmi $$(docker images -q -f reference='*inception*') 2>/dev/null || true
	@docker rmi $$(docker images -q -f reference='srcs-*') 2>/dev/null || true
	@echo "Images removed"

fclean: clean
	@echo "FULL CLEANUP - Removing EVERYTHING..."
	@echo "Removing containers with volumes..."
	$(DOCKER_COMPOSE) down -v --rmi all --remove-orphans >/dev/null 2>&1 || true
	@echo "Removing all Docker volumes..."
	@docker volume prune -f >/dev/null 2>&1 || true
	@echo "Removing all Docker images..."
	@docker image prune -a -f >/dev/null 2>&1 || true
	@echo "Removing build cache..."
	@docker builder prune -a -f >/dev/null 2>&1 || true
	@echo "Removing persistent data..."
	@sudo rm -rf $(DATA_PATH) >/dev/null 2>&1 || true
	@echo "COMPLETE CLEANUP DONE"

# =========================
# REBUILD TARGET
# =========================
re: fclean all
	@echo "Full rebuild completed"

# =========================
# MANAGEMENT TARGETS
# =========================
logs:
	@$(DOCKER_COMPOSE) logs -f

ps:
	@$(DOCKER_COMPOSE) ps