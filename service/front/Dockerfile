# ── Stage 1: React 빌드 ────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install

COPY . .
# 타입 체크는 CI lint 단계에서 별도 수행 — 여기서는 번들링만
RUN npx vite build

# ── Stage 2: nginx로 정적 파일 서비스 ─────────────────────────────────────────
FROM nginx:1.27-alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
