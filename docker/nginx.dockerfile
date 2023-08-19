FROM nginx:stable-alpine

LABEL maintainer="Rahul Baruah <baruah.rahul.88@gmail.com>"

# install necessary alpine packages
RUN apk update

# environment arguments
ARG UID
ARG GID
ARG DOCKER_USER
ARG DOCKER_GROUP

ENV UID=${UID}
ENV GID=${GID}
ENV DOCKER_USER=${DOCKER_USER}
ENV DOCKER_GROUP=${DOCKER_GROUP}

# Dialout group in alpine linux conflicts with MacOS staff group's gid, whis is 20. So we remove it.
RUN delgroup dialout

# Creating user and group
RUN addgroup -g ${GID} --system ${DOCKER_GROUP}
RUN adduser -G ${DOCKER_GROUP} --system -D -s /bin/sh -u ${UID} ${DOCKER_USER}

# Modify nginx configuration to use the new user's priviledges for starting it.
RUN sed -i "s/user nginx/user '${DOCKER_USER}'/g" /etc/nginx/nginx.conf

COPY ./docker/nginx/conf.d/*.conf /etc/nginx/conf.d/

# RUN mkdir -p /etc/nginx/certs/
# ADD ./docker/nginx/certs/mkcert /etc/nginx/certs/

RUN mkdir -p /etc/nginx/certs/
COPY ./docker/nginx/certs/selfsigned /etc/nginx/certs/

# RUN mkdir -p /var/www/html