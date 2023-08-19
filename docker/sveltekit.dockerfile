FROM node:19.4.0 as build

WORKDIR /sveltekit-app

RUN rm -rf node_modules
RUN rm -rf build
COPY ./src/sveltekit-app/package*.json ./
COPY ./src/sveltekit-app/ .
RUN npm install
RUN npm run build

FROM node:19-alpine3.15 as run

WORKDIR /sveltekit-app
COPY --from=build /sveltekit-app/package.json ./package.json
COPY --from=build /sveltekit-app/build ./build
RUN npm install --production

ARG DOCKER_USER
ARG DOCKER_GROUP

ENV DOCKER_USER=${DOCKER_USER}
ENV DOCKER_GROUP=${DOCKER_GROUP}

RUN addgroup -S ${DOCKER_GROUP} && \
    adduser -S ${DOCKER_USER} -G ${DOCKER_GROUP} && \
    chown -R ${DOCKER_USER}:${DOCKER_GROUP} /sveltekit-app

USER ${USER}
EXPOSE 3000
ENTRYPOINT [ "npm", "run", "start" ]