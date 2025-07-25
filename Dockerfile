# Use Ubuntu LTS since openjdk:jre doesn't have graphviz or a package manager for installing it.
FROM ubuntu:latest AS builder

RUN mkdir /build
WORKDIR /build

# Install PlantUML dependencies
RUN apt-get -y update
RUN apt-get install -y openjdk-18-jre-headless wget graphviz

# Get a PlantUML distribution directly
RUN wget https://github.com/plantuml/plantuml/releases/download/v1.2025.4/plantuml-1.2025.4.jar -O plantuml.jar

COPY . .
RUN ./build.sh
RUN rm *.jar

FROM nginx:stable-alpine AS server
LABEL maintainer="preston.lee@prestonlee.com"
WORKDIR /usr/share/nginx/html

# Remove any default nginx content
RUN rm -rf *

# Use our own configuration file with directory indexing enabled
COPY nginx.conf /etc/nginx/conf.d/default.conf
WORKDIR /usr/share/nginx/html

# Copy in our stuff
COPY --from=builder /build/**/*.png ./
COPY --from=builder /build/**/*.svg ./

# The CMD line is already specified in the parent image
