

# Build stage
FROM node:20-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git python3 make g++

# Set the working directory
WORKDIR /usr/src/app

# Clone the repository
RUN git clone https://github.com/barrychum/svg-term-cli.git .

# Install dependencies
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Build the application (if a build script exists)
# RUN npm run build || echo "No build script found, continuing..."

# Production stage
FROM node:20-alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if it exists)
COPY --from=builder /usr/src/app/package*.json ./

# Copy the entire app directory
COPY --from=builder /usr/src/app .

# Install production dependencies
RUN npm ci --only=production || npm install --only=production

# Install svg-term-cli globally
RUN npm install -g svg-term-cli && npm cache clean --force

# Remove unnecessary files
RUN rm -rf .git \
    node_modules/.cache \
    node_modules/.npm \
    node_modules/.staging \
    node_modules/*/test \
    node_modules/*/tests \
    node_modules/*/docs \
    node_modules/*/examples

# Entrypoint to pass arguments
ENTRYPOINT ["svg-term"]
