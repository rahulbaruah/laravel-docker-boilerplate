FROM alpine:3.18.2

# install necessary alpine packages
RUN apk update && apk add --no-cache \
    busybox-extras \
    beanstalkd

# ENTRYPOINT beanstalkd -l 127.0.0.1 -p 14710 && /bin/sh
ENTRYPOINT beanstalkd && /bin/sh