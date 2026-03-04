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

# Сборка Docker-образа приложения
docker-build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Запуск приложения в контейнере
docker-run:
	docker run --rm -p 8080:8080 -p 9090:9090 $(IMAGE_NAME):$(IMAGE_TAG)

lint:
	./gradlew spotlessCheck

lint-fix:
	./gradlew spotlessApply

.PHONY: build docker-build docker-run
