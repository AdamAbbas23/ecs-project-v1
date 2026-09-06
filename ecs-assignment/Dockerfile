# FROM node:20-alpine
# WORKDIR /app
# COPY . .
# RUN yarn install
# EXPOSE 3000
# CMD ["yarn", "start"]

# build

# FROM node:20-alpine AS build
# WORKDIR /app
# COPY . .
# RUN yarn install
# RUN yarn build

FROM node:22-alpine AS build
WORKDIR /app
COPY . .
RUN apk add --no-cache python3 make g++
RUN yarn install
RUN yarn build

#production

FROM nginx:1.28.1-alpine
WORKDIR /app
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]