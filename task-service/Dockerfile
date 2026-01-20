FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
# Copy parent pom first
COPY pom.xml /workspace/pom.xml
# Copy all module directories (needed for Maven multi-module build)
COPY task-service /workspace/task-service
COPY user-service/pom.xml /workspace/user-service/pom.xml
COPY api-gateway/pom.xml /workspace/api-gateway/pom.xml
# Build only the task-service module
WORKDIR /workspace
RUN mvn clean package -DskipTests -pl task-service -am

FROM eclipse-temurin:17-jre
WORKDIR /app
# Copy the Spring Boot executable JAR (not the plain JAR)
COPY --from=build /workspace/task-service/target/task-service-1.0.0.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]
