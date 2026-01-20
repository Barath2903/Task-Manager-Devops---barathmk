FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
# Copy parent pom first
COPY pom.xml /workspace/pom.xml
# Copy all module directories (needed for Maven multi-module build)
COPY api-gateway /workspace/api-gateway
COPY task-service/pom.xml /workspace/task-service/pom.xml
COPY user-service/pom.xml /workspace/user-service/pom.xml
# Build only the api-gateway module
WORKDIR /workspace
RUN mvn clean package -DskipTests -pl api-gateway -am

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/api-gateway/target/api-gateway-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
