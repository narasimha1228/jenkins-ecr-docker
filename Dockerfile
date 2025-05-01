# 1st Stage: Build the Java application
FROM maven:3.9.4-eclipse-temurin-17 AS build

# Set working directory inside the container
WORKDIR /build

# Copy pom.xml separately first to leverage Docker layer caching
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline

# Copy the source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# 2nd Stage: Create the final minimal runtime image with Distroless
FROM gcr.io/distroless/java17-debian11

# Set working directory (optional for clarity)
WORKDIR /app

# Copy only the final JAR from build stage
COPY --from=build /build/target/*.jar app.jar
EXPOSE 8081
# Run the Java application
CMD ["app.jar"]
