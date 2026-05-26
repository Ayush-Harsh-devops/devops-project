# ============================================
# Backend Dockerfile — Production Grade
# ============================================

# Stage 1: Dependencies
FROM node:18-alpine AS deps

RUN apk add --no-cache \
    libc6-compat \
    python3 \
    make \
    g++

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --no-audit --no-fund && \
    npm cache clean --force

# Stage 2: Builder
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --no-audit --no-fund

COPY . .
RUN npm run build && \
    echo "[INFO] Build complete: $(du -sh dist/)"

# Stage 3: Production
FROM node:18-alpine AS production

ARG BUILD_DATE
ARG VCS_REF
ARG IMAGE_TAG=latest

LABEL maintainer="Ayush-Harsh-devops" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.version="${IMAGE_TAG}"

RUN apk add --no-cache \
    dumb-init \
    curl \
    tzdata && \
    rm -rf /var/cache/apk/*

ENV TZ=Asia/Kolkata \
    NODE_ENV=production \
    PORT=3000 \
    NODE_OPTIONS="--max-old-space-size=512"

WORKDIR /app

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001 -G nodejs && \
    mkdir -p /app/logs /app/tmp && \
    chown -R nodeuser:nodejs /app

COPY --from=deps    --chown=nodeuser:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodeuser:nodejs /app/dist        ./dist
COPY --chown=nodeuser:nodejs package*.json ./

USER nodeuser
EXPOSE 3000

HEALTHCHECK --interval=30s \
            --timeout=5s \
            --start-period=10s \
            --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "dist/server.js"]
