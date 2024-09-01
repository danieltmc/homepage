FROM node:18-alpine

EXPOSE 3000

WORKDIR /app

COPY . .

RUN npm ci

RUN npm run build

# CMD [ "yarn","build"]
# TODO: Define an entrypoint