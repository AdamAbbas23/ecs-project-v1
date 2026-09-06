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

FROM node:20-alpine AS build
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

#production

FROM nginx:1.28.1-alpine
WORKDIR /app
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]