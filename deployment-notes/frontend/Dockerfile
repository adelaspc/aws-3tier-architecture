FROM node:26-bookworm-slim AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN --mount=type=cache,target=/root/.npm npm ci
COPY frontend/ ./
RUN npm run build

# The final image only needs Nginx and the compiled static files, not Node.js.
FROM nginx:1.31-alpine
COPY deploy/nginx/templates/default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html
EXPOSE 80
