# =============================================================
# Stage 1: Dependency Installation
# =============================================================
FROM node:18-alpine AS deps

# Install system dependencies for native modules
RUN apk add --no-cache \
    libc6-compat \
    python3 \
    make \
    g++

WORKDIR /app

# Copy package files first (layer caching)
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production --no-audit --no-fund && \
    npm cache clean --force

# =============================================================
# Stage 2: Builder
# =============================================================
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --no-audit --no-fund

# Copy source code
COPY . .

# Run build if needed (React/TS/etc)
RUN if [ -f "package.json" ] && grep -q '"build"' package.json; then \
        npm run build; \
    else \
        echo "[INFO] No build step found, skipping..."; \
    fi

# =============================================================
# Stage 3: Production Runtime
# =============================================================
FROM node:18-alpine AS production

# Build metadata labels
ARG BUILD_DATE
ARG VCS_REF
ARG IMAGE_TAG=latest

LABEL maintainer="Ayush-Harsh-devops" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.version="${IMAGE_TAG}" \
      org.label-schema.description="Production Node.js App" \
      org.label-schema.schema-version="1.0"

# Install runtime security tools + curl for healthcheck
RUN apk add --no-cache \
    dumb-init \
    curl \
    tzdata && \
    rm -rf /var/cache/apk/*

# Set timezone
ENV TZ=Asia/Kolkata

WORKDIR /app

# Create non-root user & group
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001 -G nodejs && \
    mkdir -p /app/logs /app/tmp && \
    chown -R nodeuser:nodejs /app

# Copy production node_modules from deps stage
COPY --from=deps --chown=nodeuser:nodejs /app/node_modules ./node_modules

# Copy built app from builder stage
COPY --from=builder --chown=nodeuser:nodejs /app/dist ./dist 2>/dev/null || true
COPY --from=builder --chown=nodeuser:nodejs /app/src ./src 2>/dev/null || true
COPY --chown=nodeuser:nodejs server.js ./
COPY --chown=nodeuser:nodejs package*.json ./

# Switch to non-root user
USER nodeuser

# Expose app port
EXPOSE 3000

# Environment defaults
ENV NODE_ENV=production \
    PORT=3000 \
    NODE_OPTIONS="--max-old-space-size=512"

# Healthcheck using curl
HEALTHCHECK --interval=30s \
            --timeout=5s \
            --start-period=10s \
            --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Use dumb-init to handle signals properly (no zombie processes)
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "server.js"]
