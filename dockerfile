# Base on Node.js Alpine for a smaller image size
FROM node:23-alpine AS build

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Set working directory
WORKDIR /app

# Copy package.json and pnpm-lock.yaml
COPY package.json pnpm-lock.yaml* ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy the rest of the application
COPY . .

# Build the application
RUN pnpm run build

# Production stage
FROM node:23-alpine AS production

# Set working directory
WORKDIR /app

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copy built application from build stage
COPY --from=build /app/.output /app/.output
COPY --from=build /app/package.json /app/pnpm-lock.yaml* ./

# Expose the application port
EXPOSE 65001

# Set environment variable for Nuxt to use the custom port
ENV PORT=65001
ENV NODE_ENV=production

# Start the application
CMD ["node", ".output/server/index.mjs"]