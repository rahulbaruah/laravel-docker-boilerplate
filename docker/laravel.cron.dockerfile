FROM laravel_docker-php

RUN apk update && apk add --no-cache apk-cron

# Add docker custom crontab
COPY ./docker/crontab/laravel_docker_crontab /etc/cron.d/laravel_docker_crontab

# Update the crontab file permission
RUN chmod 0644 /etc/cron.d/laravel_docker_crontab

# Specify crontab file for running
RUN crontab /etc/cron.d/laravel_docker_crontab

# execute crontab
CMD ["crond", "-f"]