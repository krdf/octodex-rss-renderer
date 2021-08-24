FROM node:alpine as DEPENDENCIES
RUN apk add --no-cache libc6-compat
WORKDIR /build
COPY package*.json ./
RUN npm ci



FROM node:alpine as BUILDER
WORKDIR /build
COPY . .
COPY --from=DEPENDENCIES /build/node_modules ./node_modules
RUN npm run build



FROM node:alpine as RUNNER

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

WORKDIR /app
COPY --from=BUILDER --chown=nodejs:nodejs /build/public ./public
COPY --from=BUILDER --chown=nodejs:nodejs /build/.next ./.next
COPY --from=DEPENDENCIES --chown=nodejs:nodejs /build/node_modules ./node_modules
COPY package.json ./package.json

USER nodejs

EXPOSE 3000
CMD ["npm", "run", "start"]