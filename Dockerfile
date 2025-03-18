# Build Stage
FROM openjdk:17-slim as builder

WORKDIR /usr/src/app/

COPY . .

RUN ./mvnw clean package -DskipTests

# Runtime Stage
FROM openjdk:17-slim

WORKDIR /usr/src/app/

# Copy built JAR file from the builder stage
COPY --from=builder /usr/src/app/target/*.jar /usr/src/app/crewmeisterchallenge-0.0.1-SNAPSHOT.jar

# Install MySQL client for database connectivity
RUN apt-get update && apt-get install -y default-mysql-client

# Expose the application port
EXPOSE 8080

# Set entry point to run 
ENTRYPOINT ["java", "-jar", "crewmeisterchallenge-0.0.1-SNAPSHOT.jar"]