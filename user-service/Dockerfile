FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
# Copy parent pom first
COPY pom.xml /workspace/pom.xml
# Copy all module directories (needed for Maven multi-module build)
COPY user-service /workspace/user-service
COPY task-service/pom.xml /workspace/task-service/pom.xml
COPY api-gateway/pom.xml /workspace/api-gateway/pom.xml
# Build only the user-service module
WORKDIR /workspace
RUN mvn clean package -DskipTests -pl user-service -am

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/user-service/target/user-service-1.0.0.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "app.jar"]
