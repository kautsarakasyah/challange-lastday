# Base image dengan JDK 17 (cocok untuk Spring Boot 2.7+ atau 3.x)
FROM eclipse-temurin:17-jdk

# Buat workdir di dalam container
WORKDIR /app

# Salin hasil build Maven ke dalam image
COPY target/*.jar app.jar

# Jalankan aplikasi
ENTRYPOINT ["java", "-jar", "app.jar"]
