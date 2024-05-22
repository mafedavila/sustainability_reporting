# Stage 1: Build the Angular application
FROM node:18 as build
WORKDIR /usr/src/app

RUN npm install -g @angular/cli
COPY . .

RUN npm install
RUN ng build

# Stage 2: Serve the application with a lightweight web server
FROM nginx:alpine
COPY --from=build /usr/src/app/dist/expandable-sidenav /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
