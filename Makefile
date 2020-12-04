SHELL := /bin/bash
.PHONY: help

help: ## Display usage
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

up: ## Start docker-compose
	@echo "Starting docker-compose..."
	@for i in sessions views cache; do mkdir -p storage/framework/$$i; done \
    && mkdir -p storage/framework/cache/data \
    && mkdir -p storage/logs \
    && chmod -R 755 storage/
	docker-compose up --build

down: ## Clean up docker-compose environment
	@echo "Cleaning up docker-compose environment..."
	docker-compose down

migrate: ## Run php artisan migrate in container
	@docker exec -it blog-app /bin/sh -c 'php artisan migrate --force'

seed: ## Run php artisan db:seed in container
	@docker exec -it blog-app /bin/sh -c 'php artisan db:seed'
