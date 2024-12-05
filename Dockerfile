# Build stage for Node.js
FROM node:18-alpine AS frontend-builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
RUN npm i sharp
COPY . .
RUN npm run build

# Build stage for Python
FROM python:3.11-alpine AS backend-builder
WORKDIR /app
COPY requirements.txt .
# Install build dependencies
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    python3-dev \
    libffi-dev \
    openssl-dev \
    && pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps

COPY ./api ./api

# Final stage
FROM python:3.11-alpine
WORKDIR /app

# Copy start script first
COPY start.sh ./
RUN chmod +x start.sh

# Install Node.js and required packages
RUN apk add --no-cache nodejs npm

# Copy requirements.txt and install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Create a non-root user
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

# Copy Python dependencies and files
COPY --from=backend-builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=backend-builder /app/api ./api

# Copy Next.js standalone build
COPY --from=frontend-builder /app/.next/standalone ./
COPY --from=frontend-builder /app/.next/static ./.next/static
COPY --from=frontend-builder /app/public ./public

# Set ownership for the app directory
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000 8000
CMD ["./start.sh"] 