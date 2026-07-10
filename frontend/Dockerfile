FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY index.html ./
COPY src ./src
RUN npm run build

FROM nginx:1.27-alpine
RUN apk --no-cache upgrade
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/dist /usr/share/nginx/html
RUN test -s /usr/share/nginx/html/index.html
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
ENV BACKEND_HOST=127.0.0.1
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]