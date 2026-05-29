.DEFAULT_GOAL := all

.PHONY: all setup build up stop down clean fclean re logs ps

# =========================
# VARIABLES
# =========================
# For 42 School environment: set to your login (e.g., mipinhei.42.fr)
DOMAIN_NAME ?= mipinhei.42.fr
COMPOSE_FILE = srcs/docker-compose.yml
# FIXED: Changed from hardcoded path to ${HOME}/data for flexibility
# Previously: /home/mipinhei/data
DOCKER_COMPOSE = docker compose -f $(COMPOSE_FILE) --env-file .env
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
	@echo "Access: https://$(DOMAIN_NAME)"

build:
	@echo "Building Docker images..."
	$(DOCKER_COMPOSE) build --no-cache

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
	@rm -rf $(DATA_PATH) >/dev/null 2>&1 || true
	@rm -rf ${HOME}/data
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