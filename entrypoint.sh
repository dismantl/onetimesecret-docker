#!/bin/bash

# NOTE: sed -i doesn't work when configs are mount points

# set OTS secret if supplied by ENV or if default
if [[ -n ${OTS_SECRET+x} ]]; then
  echo "Setting OTS secret to $OTS_SECRET"
  cp /etc/onetime/config{,.bak}
  sed "s/:secret:.*\$/:secret: $OTS_SECRET/" /etc/onetime/config.bak > /etc/onetime/config
elif grep -q ":secret: CHANGEME" /etc/onetime/config; then
  PASS="$(dd if=/dev/urandom bs=20 count=1 2>/dev/null| openssl sha1 | grep -o '[a-f0-9]\{40\}')"
  echo "Generating OTS secret: $PASS"
  cp /etc/onetime/config{,.bak}
  sed "s/:secret:.*\$/:secret: $PASS/" /etc/onetime/config.bak > /etc/onetime/config
fi

# set redis password if needed
if grep -q "redis://user:CHANGEME@127.0.0.1:7179" /etc/onetime/config && \
    grep -q "requirepass CHANGEME" /etc/onetime/redis.conf; then
  PASS="$(dd if=/dev/urandom bs=20 count=1 2>/dev/null| openssl sha1 | grep -o '[a-f0-9]\{40\}')"
  echo "Generating Redis password: $PASS"
  cp /etc/onetime/config{,.bak}
  cp /etc/onetime/redis.conf{,.bak}
  sed "s/.*requirepass.*\$/requirepass $PASS/" /etc/onetime/redis.conf.bak > /etc/onetime/redis.conf
  sed "s/redis:\/\/user:CHANGEME/redis:\/\/user:$PASS/" /etc/onetime/config.bak > /etc/onetime/config
fi

# change default sender name in automated emails
# (even better, create and mount your own email templates at the locations below)
if [[ -n ${OTS_NAME+x} ]]; then
  echo "Setting email sender name to $OTS_NAME"
  sed -i.bak "s/Delano/$OTS_NAME/" /home/ots/templates/email/password_request.mustache
  sed -i.bak "s/Delano/$OTS_NAME/" /home/ots/templates/email/welcome.mustache
fi

redis-server /etc/onetime/redis.conf
cd /home/ots && bundle exec thin -e dev -R config.ru -p 7143 start
