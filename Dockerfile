FROM ghcr.io/gohugoio/hugo:v0.169.0 AS build
# The image's /project is a VOLUME owned by user hugo, so build elsewhere as root.
USER root
WORKDIR /src
COPY . .
RUN hugo --gc --minify

FROM joseluisq/static-web-server:2.44.1
COPY --from=build /src/public /public
ENV SERVER_PORT=8080 SERVER_HEALTH=true
USER 65534:65534
