## Этап 1: сборка фронтенда
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend

# Устанавливаем зависимости
COPY frontend/package*.json ./
RUN npm ci

# Собираем React-приложение в frontend/dist
COPY frontend/ .
RUN npm run build


## Этап 2: сборка backend-приложения
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /app

# Копируем исходники backend
COPY . .

# Кладём собранный фронтенд в static-ресурсы Spring Boot
COPY --from=frontend-build /app/frontend/dist/ ./src/main/resources/static/

# Даём права на gradlew под Linux
RUN chmod +x ./gradlew

# Сборка, тесты и упаковка jar
RUN ./gradlew clean test bootJar --no-daemon


## Этап 3: минимальный рантайм
FROM eclipse-temurin:21-jre-jammy AS runtime
WORKDIR /app

# Профиль по умолчанию — dev с H2
ENV SPRING_PROFILES_ACTIVE=dev

# Копируем только собранный артефакт
COPY --from=build /app/build/libs/project-devops-deploy-0.0.1-SNAPSHOT.jar /app/app.jar

EXPOSE 8080 9090

# Поддерживаем JAVA_OPTS из переменных окружения
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
