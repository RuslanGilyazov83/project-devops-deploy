## Этап 1: сборка фронтенда
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend

# Сначала зависимости — слой кешируется, если package.json не менялся
COPY frontend/package*.json ./
RUN npm ci

# Затем исходники и сборка
COPY frontend/ .
RUN npm run build


## Этап 2: сборка backend
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /app

COPY . .
RUN chmod +x ./gradlew

# Собираем backend — тесты и упаковка JAR
RUN ./gradlew clean test bootJar --no-daemon

# Добавляем фронтенд в JAR через zip -r (не перепаковывает, только дополняет)
# zip требует нужной структуры папок: BOOT-INF/classes/static/
RUN apt-get update && apt-get install -y --no-install-recommends zip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/static
COPY --from=frontend-build /app/frontend/dist/ ./BOOT-INF/classes/static/
RUN zip -r /app/build/libs/project-devops-deploy-0.0.1-SNAPSHOT.jar BOOT-INF/


## Этап 3: минимальный рантайм
FROM eclipse-temurin:21-jre-jammy AS runtime
WORKDIR /app

# Профиль по умолчанию — dev с H2
ENV SPRING_PROFILES_ACTIVE=dev

COPY --from=build /app/build/libs/project-devops-deploy-0.0.1-SNAPSHOT.jar /app/app.jar

EXPOSE 8080 9090

# Поддерживаем JAVA_OPTS из переменных окружения
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
