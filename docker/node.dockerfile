FROM node:19-alpine3.15 as node

# WORKDIR /var/www/html/site12
# COPY package.json .
# RUN npm i
# COPY . .

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

# FROM node:19-alpine3.15 as run
# COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
# COPY --from=node /usr/local/bin/node /usr/local/bin/node
# RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# Only use this when no mount
# RUN mkdir -p /var/www/html

# RUN chown -R ${DOCKER_USER}:${DOCKER_GROUP} /var/www/html

# RUN mkdir /tmp/npm && \
#     chmod 2777 /tmp/npm && \
#     chown 1000:1000 /tmp/npm && \
#     npm config set cache /tmp/npm --global \
#     npm config set unsafe-perm true

# RUN mkdir -p /var/www/html
# RUN chown -R ${DOCKER_USER}:${DOCKER_GROUP} /var/www/html

# USER ${DOCKER_USER}
# WORKDIR /var/www/html/site1
# ADD ./src/site1/package*.json .
# RUN npm i

EXPOSE 5173

CMD ["npm","run","dev"]