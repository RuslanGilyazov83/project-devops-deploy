test:
	./gradlew test

start: run

run:
	./gradlew bootRun

update-gradle:
	./gradlew wrapper --gradle-version 9.2.1

update-deps:
	./gradlew refreshVersions

install:
	./gradlew dependencies

build:
	./gradlew build

# Имя Docker-образа в реестре контейнеров
IMAGE_NAME ?= ruslangilyazov/project-devops-deploy
IMAGE_TAG ?= dev
DEPLOY_TAG ?= latest

# Сборка Docker-образа приложения
docker-build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Запуск приложения в контейнере
docker-run:
	docker run --rm -p 8080:8080 -p 9090:9090 $(IMAGE_NAME):$(IMAGE_TAG)

ansible-requirements:
	ansible-galaxy install -r requirements.yml

deploy:
	ansible-playbook -i inventory.ini playbook.yml -e app_image_tag=$(DEPLOY_TAG) --ask-vault-pass

lint:
	./gradlew spotlessCheck

lint-fix:
	./gradlew spotlessApply

.PHONY: build docker-build docker-run ansible-requirements deploy
