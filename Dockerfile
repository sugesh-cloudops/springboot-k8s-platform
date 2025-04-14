# Build Stage
FROM eclipse-temurin:17-jdk-jammy AS builder

WORKDIR /app

# Copy Maven wrapper and pom.xml separately for better caching
COPY mvnw pom.xml ./
COPY .mvn .mvn

# Download dependencies (cache-friendly)
RUN ./mvnw dependency:go-offline

# Copy source code
COPY src ./src

# Package the application
RUN ./mvnw clean package -DskipTests

# Runtime Stage (minimal image)
FROM eclipse-temurin:17-jre-jammy

# Create a non-root user to run the app securely
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app

# Copy jar from builder
COPY --from=builder /app/target/*.jar app.jar

# Change ownership for security purposes
RUN chown appuser:appgroup app.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]