FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Set working directory
WORKDIR /app

# Copy only pom.xml first (so Docker cache works)
COPY pom.xml .

# Pre-download dependencies (reduces build time in Jenkins)
RUN mvn dependency:go-offline -B

# Copy the source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests


# ============================================
# Stage 2: Run the Java Application
# ============================================
FROM eclipse-temurin:17-jdk-alpine

# Set working directory inside final image
WORKDIR /app

# Copy compiled JAR from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose port (use port required by your app if applicable)
EXPOSE 8080

# Run the Java application
ENTRYPOINT ["java", "-jar", "app.jar"]
