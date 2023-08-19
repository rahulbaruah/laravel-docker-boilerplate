# Laravel Docker Workflow

This is a pretty simplified, but complete, workflow for using Docker and Docker Compose with Laravel development. The included docker-compose.yml file, Dockerfiles, and config files, set up a LEMP stack powering a Laravel application in the `src` directory.

## Usage

To get started, make sure you have [Docker installed](https://www.docker.com/get-started/) on your system, and then copy this directory to a desired location on your development machine.

Next, navigate in your terminal to that directory, and spin up the containers for the full web server stack by running

```bash
docker compose -f "docker-compose.yml" up -d --build nginx
```

_We are running the above command instead of just `docker compose up --build -d` because we want only to start the main containers. Our nginx container depends on all the other main containers; hence it will start them first._

_The -d argument runs the command in Daemon mode silently without outputting logs on your terminal._

_After the docker images building, the containers will come online one by one._

**After that completes, run the following to install and compile the dependencies for the application:**

- `docker compose run --rm --workdir /var/www/html/laravel-app php composer install`
- `docker compose run --rm --workdir /var/www/html/laravel-app artisan migrate`
- `docker compose run --rm --workdir /var/www/html/laravel-app artisan db:seed`
- `cd ./src/laravel-app`
- `npm install`
- `npm run dev`

## Folder Permissions

```bash
chown -R rahul:rahul src

chown -R rahul:rahul supervisor-logs
```

### Certbot generate SSL Certificates

`docker compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ -d example.org`

**Renew Certbot**
`docker compose run --rm certbot renew`

## Docker Ports

When the container network is up, the following services and their ports are available to the host machine:

- **nginx** = `8080`
- **mysql** = `3307`
- **phpmyadmin** = `8081`
- **vite** = `5173`
- **redis** = `6380`
- **mailhog** = `1025`, `8025`
- **meilisearch** = `7700`
- **svelteapp** = `3000`

Three additional containers are included that are not brought up with the webserver stack, and are instead used as "command services". These allow you to run commands that interact with your application's code, without requiring their software to be installed and maintained on the host machine. These are:

- `docker compose run --rm --workdir /var/www/html/laravel-app composer`
- `docker compose run --rm --workdir /var/www/html/laravel-app artisan`
- `docker compose run --rm --workdir /var/www/html/laravel-app npm`

---

## Composer install

`docker compose run --rm --workdir /var/www/html/laravel-app composer install --ignore-platform-reqs`

(Or)

`composer install --ignore-platform-reqs`

---

## Vite SSL Config

- use mkcert() plugin for Windows
- user basicSsl() plugin for WSL (Ubuntu)

## Windows, Install mkcert to setup ssl locally

`choco install mkcert`
`mkcert -install`
`cd .\docker\nginx\certs\mkcert`
`mkcert laravel-app.test`

**Add to `etc/hosts`**

```text
127.0.0.1 localhost
255.255.255.255 broadcasthost
::1             localhost
127.0.0.1 laravel-app.test
127.0.0.1 admin.laravel-app.test
```

---

## Ubuntu, generate self signed SSL certificate

```bash
cd docker/nginx/certs/selfsigned
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx-selfsigned.key -out nginx-selfsigned.crt
```

---

## PHP Cs Fixer

The PHP Coding Standards Fixer (PHP CS Fixer) tool fixes your code to follow standards; whether you want to follow PHP coding standards as defined in the PSR-1, PSR-2, etc., or other community driven ones like the Symfony one. You can also define your (team's) style through configuration.

```bash
wget https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/v3.14.4/php-cs-fixer.phar -O php-cs-fixer

chmod +x php-cs-fixer

sudo mv php-cs-fixer /usr/local/bin/php-cs-fixer

sudo chown -R user name: /usr/local/bin/php-cs-fixer

#php-cs-fixer fix
```

In the Vscode executable path field, enter the following:
`/usr/local/bin/php-cs-fixer`

That should be it! You can lint your code now: press `F1` or `ctrl + Shift + I`

---

## Access Docker shell

`docker exec -it php /bin/sh`

`docker compose run --rm --workdir /var/www/html/laravel-app php`

`docker compose run --rm --workdir /var/www/html/laravel-app artisan`

`docker compose run --rm --workdir /var/www/html/laravel-app npm`

`docker compose run --rm --workdir /var/www/html/laravel-app composer install`

---

## Running Frontend

`npm run dev` (Preferred)

(OR)

`docker compose run --rm  --workdir /var/www/html/laravel-app npm run dev`

## Sveltekit app

`docker compose build app-node`

## Phpmyadmin

```text
<http://localhost:8080/>

Server: **mysql**

Username: **laravel**

Password: **secret**
```

## Php CS Fixer

Installation

`composer require friendsofphp/php-cs-fixer --dev`

Edit `.vscode/settings.json`

For Windows

```text
"php-cs-fixer.executablePath": "C:\\Users\\Rahul\\AppData\\Roaming\\Composer\\vendor\\bin\\php-cs-fixer.bat",
    "php-cs-fixer.executablePathWindows": "C:\\Users\\Rahul\\AppData\\Roaming\\Composer\\vendor\\bin\\php-cs-fixer.bat",
```

For Ubuntu

```text
"php-cs-fixer.executablePath": "${workspaceFolder}/vendor/bin/php-cs-fixer",
```

## Laravel Exception open in VSCode

Add to `src/laravel-app/.env`

```text
IGNITION_LOCAL_SITES_PATH="C:\\Docker\\getkraft_v3\\src\\laravel-app"
```

## Certbot

`docker-compose run --rm certbot certonly --webroot --webroot-path=/var/www/certbot/ --email test@test.com --agree-tos --no-eff-email -d getkraftv3.dit-soft.com`

## Troubleshoot Images

`docker run --rm -it rahulbaruah/php-base:8.1.3-fpm-alpine3.15 /bin/sh`

## No Cache Build

`docker compose build --no-cache <svelte-node-app>`

## Permissions Issues

Rebuilding your Docker network with `docker compose -f "docker-compose.yml" up -d --build` should resolve any permissions issues during site loads, composer installations, or artisan commands.

## You can verify this with the convert command, which prints your resolved application config to the terminal

```bash
docker compose convert
```

## Port already in use

```bash
docker compose down  # Stop container on current dir if there is a docker-compose.yml
docker rm -fv $(docker ps -aq)  # Remove all containers
sudo lsof -i -P -n | grep <port number>  # List who's using the port
sudo kill <process id>
```

## npm run dev error: ENOSPC: System limit for number of file watchers reached

```bash
# insert the new value into the system config
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# check that the new value was applied
cat /proc/sys/fs/inotify/max_user_watches
```

## Adduser Help

-s SHELL Login shell
-G GRP Group
-D Don't assign a password
-u UID User id

## Opcache

For `opcache.max_accelerated_files`.

You can run `find . -type f -print | grep php | wc -l` to quickly calculate the number of files in your codebase.

Once you make the change, you need to restart PHP FPM:

```bash
systemctl restart php8.1-fpm.service
```

## Beanstalkd Debugging

- `docker exec -it beanstalkd /bin/sh`

- `telnet localhost 11300` // for access the beanstalk

- `list-tubes` // try this command to see list of tasks

- `use default` //To use that tube

- `peek-ready` //To see if there are any ready jobs

- `stats-tube default` //To get the stats for that tube
