#!/bin/sh

# todo: version

echo "
-------------------------------------
 _ _  ___  __ __       _
| \ || . \|  \  \ ___ | | _ _  ___
|   ||  _/|     || . \| || | |[_-[
|_\_||_|  |_|_|_||  _/|_| \__|/__/
                 |_|
-------------------------------------
Version:  $(jq -r .version /app/package.json)
Date:     $(date)
User:     $(whoami)
PUID:     $PUID
User ID:  $(id -u)
PGID:     $PGID
Group ID: $(id -g)
-------------------------------------
"

if ! nginx -tq; then
    sleep inf
fi

if [ "$PHP82" = "true" ]; then
    if ! PHP_INI_SCAN_DIR=/data/php/82/conf.d php-fpm82 -c /data/php/82 -y /data/php/82/php-fpm.conf -FORt > /dev/null 2>&1; then
        PHP_INI_SCAN_DIR=/data/php/82/conf.d php-fpm82 -c /data/php/82 -y /data/php/82/php-fpm.conf -FORt
        sleep inf
    fi
fi

if [ "$PHP83" = "true" ]; then
    if ! PHP_INI_SCAN_DIR=/data/php/83/conf.d php-fpm83 -c /data/php/83 -y /data/php/83/php-fpm.conf -FORt > /dev/null 2>&1; then
        PHP_INI_SCAN_DIR=/data/php/83/conf.d php-fpm83 -c /data/php/83 -y /data/php/83/php-fpm.conf -FORt
        sleep inf
    fi
fi

if ! PHP_INI_SCAN_DIR=/etc/php/conf.d php-fpm83 -c /etc/php -y /etc/php/php-fpm.conf -FORt > /dev/null 2>&1; then
    PHP_INI_SCAN_DIR=/etc/php/conf.d php-fpm83 -c /etc/php -y /etc/php/php-fpm.conf -FORt
    sleep inf
fi

cron.sh &
# shellcheck disable=SC2086
if [ "$GOA" = "true" ]; then while true; do goaccess --no-global-config --num-tests=0 --tz="$TZ" --date-format="%d/%b/%Y" --time-format="%H:%M:%S" --log-format='[%d:%t %^] %v %h %T "%r" %s %b %b %R %u' --no-ip-validation --addr=127.0.0.1 --port="$GOAIWSP" \
                                -f /data/nginx/access.log --real-time-html -o /tmp/goa/index.html --persist --restore --db-path=/data/etc/goaccess/data -b /etc/goaccess/browsers.list -b /etc/goaccess/podcast.list $GOACLA; done; fi &
if [ "$PHP82" = "true" ]; then PHP_INI_SCAN_DIR=/data/php/82/conf.d php-fpm82 -c /data/php/82 -y /data/php/82/php-fpm.conf -FOR; fi &
if [ "$PHP83" = "true" ]; then PHP_INI_SCAN_DIR=/data/php/83/conf.d php-fpm82 -c /data/php/83 -y /data/php/83/php-fpm.conf -FOR; fi &
valkey-server --protected-mode yes --loglevel warning --bind "" --unixsocket /run/valkey.sock --unixsocketperm 666 --dir "/tmp" &
PHP_INI_SCAN_DIR=/etc/php/conf.d php-fpm83 -c /etc/php -y /etc/php/php-fpm.conf -FOR &
nginx -e stderr

