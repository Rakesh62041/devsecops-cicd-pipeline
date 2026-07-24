# Stage 1 - Build the JAR
FROM maven:3.8.3-openjdk-17 AS builder

WORKDIR /app

COPY . .

RUN mvn clean install -DskipTests=true

# Stage 2 - Run the application
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=builder /app/target/*.jar /app/expenseapp.jar

EXPOSE 8080

CMD ["java", "-jar", "expenseapp.jar"]
