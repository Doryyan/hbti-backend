FROM node:20-slim

WORKDIR /app

# Create data directory for SQLite
RUN mkdir -p /app/data

# Copy package files and install deps
COPY backend/package.json backend/package-lock.json ./
RUN npm install --production

# Copy backend source code
COPY backend/ .

# The SQLite database is ephemeral on Render's disk (stored in /app/data/)
# For production persistence, consider using an external database

EXPOSE 3000

CMD ["node", "server.js"]
