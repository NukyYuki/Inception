NAME = inception
DOCKER_COMPOSE = sudo docker compose -f srcs/docker-compose.yml
#DATA_PATH = /home/mipinhei/data
DATA_PATH = /home/$(USER)/data

all: setup
	@echo "Inception Built"
	$(DOCKER_COMPOSE) up -d --build

setup:
	@echo "Setting up data directories..."
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@sudo chmod 777 $(DATA_PATH)/mariadb
	@sudo chmod 777 $(DATA_PATH)/wordpress

stop:
	@echo "Stopping containers..."
	$(DOCKER_COMPOSE) stop

down:
	@echo "Stopping and removing containers, networks, volumes, and images..."
	$(DOCKER_COMPOSE) down

clean: down
	@echo "Cleaning up data directories..."
	$(DOCKER_COMPOSE) down

fclean: clean
	@echo "Everything clean"
	@sudo rm -rf $(DATA_PATH)
	@if [ -n "$$(sudo docker volume ls -q)" ]; then \
		sudo docker volume rm $$(sudo docker ls -q); \
	fi

re: fclean all

.PHONY: all setup stop down clean fclean re