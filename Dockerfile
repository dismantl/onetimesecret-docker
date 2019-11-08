# Dockerfile for One-Time Secret
# http://onetimesecret.com

FROM ruby:2.3

MAINTAINER Dan Staples <dan@disman.tl>

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update && \
  apt-get install -y \
    build-essential \
    redis-server \
  && rm -rf /var/lib/apt/lists/*

# OTS pre-installation
RUN set -ex && \
  # Add ots user
  useradd -U -m -s /bin/false ots && \
  \
  # Create directories
  mkdir -p /etc/onetime /var/log/onetime /var/run/onetime /var/lib/onetime && \
  chown ots /etc/onetime /var/log/onetime /var/run/onetime /var/lib/onetime

USER ots

# Download and install OTS version 0.10.x
RUN set -ex && \
  wget https://codeload.github.com/onetimesecret/onetimesecret/legacy.tar.gz/0.10 -O /tmp/ots.tar.gz && \
  tar xzf /tmp/ots.tar.gz -C /home/ots --strip-components=1 && \
  rm /tmp/ots.tar.gz && \
  cd /home/ots && \
  bundle install --frozen --deployment --without=dev && \
  cp -R etc/* /etc/onetime/

ADD entrypoint.sh /usr/bin/

VOLUME /etc/onetime /var/lib/onetime/redis

EXPOSE 7143/tcp

ENTRYPOINT /usr/bin/entrypoint.sh
