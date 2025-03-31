# Build Stage
FROM eclipse-temurin:17-jdk-jammy as builder

WORKDIR /app

# Pre-cache dependencies
COPY pom.xml mvnw ./
COPY .mvn .mvn
RUN ./mvnw dependency:go-offline

# Copy source files
COPY src ./src

# Build the app
RUN ./mvnw clean package -DskipTests

# Runtime Stage (smallest possible)
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]