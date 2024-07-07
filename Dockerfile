FROM node:20-alpine

# Install dependencies
RUN apk add --no-cache git python3 make g++

# Set the working directory
WORKDIR /usr/src/app

# Clone the repository
RUN git clone https://github.com/barrychum/svg-term-cli.git .

# Install dependencies
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Build the application
RUN npm run build || echo "No build script found, continuing..."

# Install svg-term-cli globally
RUN npm install -g svg-term-cli

# Clean up
RUN apk del git python3 make g++ && \
    rm -rf .git && \
    npm cache clean --force

# Entrypoint to pass arguments
ENTRYPOINT ["svg-term"]