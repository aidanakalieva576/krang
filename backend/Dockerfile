# -------- build stage --------
FROM --platform=$BUILDPLATFORM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY . .

RUN chmod +x mvnw || true
RUN ./mvnw -B -DskipTests package

# -------- run stage --------
FROM --platform=$TARGETPLATFORM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Копируем jar (берём любой jar из target)
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
