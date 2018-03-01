FROM node:alpine
MAINTAINER ember@pfragoso.org

RUN apk upgrade --no-cache && \
     rm -rf /var/cache/apk/*

USER node
WORKDIR /home/node

COPY . .

RUN yarn install --frozen-lockfile

CMD ["yarn", "run", "start"]
EXPOSE 3000


