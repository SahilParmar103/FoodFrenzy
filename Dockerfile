# Start with an official OpenJDK 17 image
FROM eclipse-temurin:17-jdk-alpine

# Set environment variables
ENV APP_HOME=/app
WORKDIR $APP_HOME

# Copy the JAR file built by Maven (adjust path if needed)
COPY target/FoodFrenzy-0.0.1-SNAPSHOT.jar app.jar

# Expose the port used by Spring Boot
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
