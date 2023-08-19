FROM composer:latest

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

# Only use this when no mount
# RUN chown -R ${DOCKER_USER}:${DOCKER_GROUP} /var/www/html

# WORKDIR /var/www/html