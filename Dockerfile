# === Stage 1: Build ===
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /build

# Salin semua file Maven
COPY pom.xml .
COPY src ./src

# Build project
RUN mvn clean package -DskipTests

# === Stage 2: Run ===
FROM eclipse-temurin:17-jdk

WORKDIR /app

# Ambil jar dari stage build
COPY --from=build /build/target/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
