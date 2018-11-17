ARG NODE_VERSION=11.1-alpine
ARG NGINX_VERSION=stable-alpine

FROM node:${NODE_VERSION} AS base
ARG MODE=production
WORKDIR /app

# Building dependencies
FROM base AS dependencies
# npm caching optimization
COPY package.json /app/
RUN npm install
COPY . /app/

# Run tests
FROM dependencies AS test
RUN yarn run lint && \
    yarn run test:unit

# Build static website
FROM dependencies AS build
RUN yarn run build --mode ${MODE}

# Copy static files to nginx
FROM nginx:${NGINX_VERSION}
COPY ./config/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
