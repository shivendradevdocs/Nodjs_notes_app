# Dockerfile - for fazt/nodejs-notes-app
FROM node:18-alpine

# Install optional build tools if native modules are required
RUN apk add --no-cache --virtual .build-deps gcc g++ make python3

WORKDIR /usr/src/app

# Copy package manifests first to leverage Docker layer cache
COPY package*.json ./

# Install production dependencies (works with or without package-lock.json)
RUN npm install --production --silent
RUN npm install dotenv --production

# Copy app source
COPY . .

# Remove build deps to slim image
RUN apk del .build-deps || true

# Default envs (override at runtime)
ENV NODE_ENV=production
# Default port the app will listen on (set PORT at run time if different)
ENV PORT=3000
# Default mongodb uri (override with real DB or Atlas URI)
ENV MONGODB_URI="mongodb://mongo:27017/notes-app"

EXPOSE 3000/tcp

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD wget -q -O- --tries=1 --timeout=3 http://localhost:${PORT}/ || exit 1

# Use whatever start command is defined in package.json (README mentions `npm start`)
CMD ["npm", "start"]
