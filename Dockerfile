ARG NODE_VERSION=11.1-alpine
ARG NGINX_VERSION=stable-alpine

FROM node:${NODE_VERSION} as build
ARG MODE=production
WORKDIR /app

# npm caching optimization
COPY package.json /app/
RUN npm install

COPY . /app
RUN yarn run build --mode ${MODE}

FROM nginx:${NGINX_VERSION}

COPY ./config/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
