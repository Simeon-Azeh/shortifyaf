# Frontend Dockerfile for production
# Use Node.js 20 Alpine for building the React app (Vite requires Node.js 20+)
FROM node:20-alpine AS builder

# Accept build argument for API URL
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies needed for building)
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Use Caddy to serve the built static files
FROM caddy:2-alpine

# Copy built files from builder stage to /srv which Caddy serves by default
COPY --from=builder /app/dist /srv
COPY Caddyfile /etc/caddy/Caddyfile

# Expose port 80
EXPOSE 80

# Start Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]