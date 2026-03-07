## Этап 1: сборка фронтенда
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend

# Сначала зависимости — слой кешируется, если package.json не менялся
COPY frontend/package*.json ./
RUN npm ci

# Затем исходники и сборка
COPY frontend/ .
RUN npm run build


## Этап 2: сборка backend — Gradle включит фронтенд в JAR через processResources
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /app

COPY . .

# Кладём собранный фронтенд туда, откуда Gradle его заберёт
COPY --from=frontend-build /app/frontend/dist/ ./frontend/dist/

RUN chmod +x ./gradlew

# processResources подхватит frontend/dist и упакует как статику в JAR
RUN ./gradlew clean test bootJar --no-daemon


## Этап 3: минимальный рантайм
FROM eclipse-temurin:21-jre-jammy AS runtime
WORKDIR /app

# Профиль по умолчанию — dev с H2
ENV SPRING_PROFILES_ACTIVE=dev

COPY --from=build /app/build/libs/project-devops-deploy-0.0.1-SNAPSHOT.jar /app/app.jar

EXPOSE 8080 9090

# Поддерживаем JAVA_OPTS из переменных окружения
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
