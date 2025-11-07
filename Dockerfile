# -------------------------------
# STAGE 1: Build the application
# -------------------------------

FROM node:18-slim AS builder

# Set working directory inside the container
WORKDIR /app

# Copy package files and install dependencies
COPY backend/package*.json ./
RUN npm install --production

# Copy the rest of the backend code
COPY backend/ .

# -------------------------------
# STAGE 2: Run the application
# -------------------------------

# Use a smaller, secure image for final stage
FROM node:18-alpine

# Create a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy only the built backend from the builder stage
COPY --from=builder /app .

# Expose the backend port
EXPOSE 3000

# Set environment variable (optional)
ENV NODE_ENV=production

# Change ownership to non-root user
USER appuser

# Command to start the server
CMD ["node", "server.js"]
