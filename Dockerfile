FROM node:lts-alpine as builder

WORKDIR /app

RUN set -x \
  && apk --no-cache update \
  && apk --no-cache upgrade \
  && echo

COPY package*.json ./
RUN npm ci --quiet
COPY . .

FROM node:lts-alpine

WORKDIR /app

COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules

RUN set -x \
  && apk --no-cache update \
  && apk --no-cache upgrade \
  \
  # Add the packages
  && apk add --no-cache dumb-init \
  # Do some cleanup
  # && apk del --no-cache make gcc g++ binutils-gold gnupg libstdc++ \
  && rm -rf /usr/include \
  && rm -rf /var/cache/apk/* /root/.node-gyp /usr/share/man /tmp/* \
  && echo

CMD ["dumb-init", "node", "./node_modules/.bin/agendash"]
