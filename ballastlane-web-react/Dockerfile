# syntax=docker/dockerfile:1

# Production Dockerfile for React frontend
# Build: docker build -t worldwise_frontend .
# Run: docker run -d -p 80:80 --name worldwise_frontend worldwise_frontend

# Stage 1: Build
FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built assets
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
