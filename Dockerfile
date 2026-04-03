FROM node:22-alpine AS build
WORKDIR /app

# Copy dependency files
COPY package*.json bun.lock* ./

# Install dependencies using bun if bun.lock exists, fallback to npm
RUN if [ -f "bun.lock" ]; then npx bun install; else npm ci; fi

# Copy source code
COPY . .

# Build the Astro project
RUN if [ -f "bun.lock" ]; then npx bun run build; else npm run build; fi

# Serve stage using lightweight Nginx
FROM nginx:alpine

# Copy built Astro static site from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Expose default Nginx port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
