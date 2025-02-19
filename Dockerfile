# Use an official Node.js runtime as a parent image
FROM node:18-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json first (for caching layers) and install dependencies
COPY package.json yarn.lock ./

# Install Dependencies
RUN yarn install --frozen-lockfile

# Copy source code
COPY . .

# Build the TypeScript project then delete node_modules then 
RUN yarn run build
RUN rm -rf node_modules && yarn install --production --frozen-lockfile

# Stage 2: Production Stage (Distroless)
FROM gcr.io/distroless/nodejs18

# Set working directory
WORKDIR /app

# Copy only necessary build artifacts
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/package.json /app/package.json

# Expose the Websocket port
EXPOSE 3000

# Add a health check for WebSocket availability
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD nc -z localhost 3000 || exit 1

# Switch to the non-root user, no need to create a secure user since distroless already provides one
USER nonroot

# Define the entrypoint and command
CMD ["./dist/index.js"]
