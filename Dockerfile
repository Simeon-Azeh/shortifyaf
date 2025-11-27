# Use Node.js 18 LTS as the base image for a stable, secure runtime
FROM node:18-alpine


# Set working directory inside the container
WORKDIR /app

# Copy package files first for better caching
COPY backend/package*.json ./

# Install only production dependencies to keep image size small
RUN npm install -g npm@10.6.0 &&npm ci --only=production

# Copy the backend application code
COPY backend/ .


# .env is intentionally not copied into the image for security reasons.
# The runtime environment (docker-compose or host) should provide required env vars.

# Create a non-root user for security best practices
RUN addgroup -g 1001 -S nodejs && \
  adduser -S -u 1001 -G nodejs nodejs

# Change ownership of the app directory to the non-root user
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose the port the application runs on
EXPOSE 3001

# Health check to ensure the application is running properly
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

# Start the application
CMD ["npm", "start"]
