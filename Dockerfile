# Dockerfile for One-Time Secret
# http://onetimesecret.com

FROM ruby:2.6

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update && \
  apt-get install -y \
    build-essential \
    redis-server \
  && rm -rf /var/lib/apt/lists/*

# Download and install OTS version 0.10.x
RUN set -ex && \
  mkdir -p /etc/onetime /var/log/onetime /var/run/onetime /var/lib/onetime && \
  wget https://github.com/onetimesecret/onetimesecret/archive/master.zip -O /tmp/ots.zip && \
  cd /tmp && unzip /tmp/ots.zip && \
  mv -fv /tmp/onetimesecret-master/* /var/lib/onetime/ && \
  rm -fr /tmp/ots.zip /tmp/onetimesecret-master && \
  cd /var/lib/onetime && \
  bundle update --bundler && \
  bundle install --frozen --deployment --without=dev && \
  cp -R etc/* /etc/onetime/

ADD entrypoint.sh /usr/bin/

# Add default config
ADD config.example /etc/onetime/config

VOLUME /etc/onetime /var/run/redis

EXPOSE 7143/tcp

ENTRYPOINT /usr/bin/entrypoint.sh
