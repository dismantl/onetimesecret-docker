# Dockerfile for One-Time Secret
# http://onetimesecret.com

FROM debian:stretch

MAINTAINER Dan Staples <dan@disman.tl>

# Install build dependencies
# RUN DEBIAN_FRONTEND=noninteractive \
#  apt-get update && \
#  apt-get install -y \
#    build-essential \
#    ntp \
#    libyaml-dev \
#    libevent-dev \
#    zlib1g \
#    zlib1g-dev \
#    openssl \
#    libssl-dev \
#    libxml2 \
#    libreadline-gplv2-dev \
#  && rm -rf /var/lib/apt/lists/*

# Install Ruby 1.9.3
#RUN set -ex && \
#  curl -O https://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p362.tar.bz2 && \
#  mkdir -p /tmp/ruby && \
#  tar xjf ruby-1.9.3-p362.tar.bz2 -C /tmp/ruby --strip-components=1 && \
#  rm ruby-1.9.3-p362.tar.bz2 && \
#  cd /tmp/ruby && \
#  ./configure \
#    --disable-install-doc && \
#  make && \
#  make install && \
#  gem install bundler && \
#  cd / && \
#  rm -rf /tmp/ruby

# Install Redis 3.2.9
#RUN set -ex && \
#  curl https://codeload.github.com/antirez/redis/legacy.tar.gz/3.2.9 -o redis.tar.gz && \
#  mkdir -p /tmp/redis && \
#  tar xzf redis.tar.gz -C /tmp/redis --strip-components=1 && \
#  rm redis.tar.gz && \
#  cd /tmp/redis && \
#  make && \
#  make install && \
#  cd / && \
#  rm -rf /tmp/redis

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update && \
  apt-get install -y \
    ruby \
    ruby-dev \
    ruby-bundler \
    redis-server \
    curl \
    build-essential

# OTS pre-installation
RUN set -ex && \
  # Add ots user
  useradd -U -s /bin/false ots && \

  # Create directories
  mkdir -p /etc/onetime /var/log/onetime /var/run/onetime /var/lib/onetime && \
  chown ots /etc/onetime /var/log/onetime /var/run/onetime /var/lib/onetime

USER ots

# Download and install latest OTS
RUN set -ex && \
  curl https://codeload.github.com/onetimesecret/onetimesecret/legacy.tar.gz/master -o /tmp/ots.tar.gz && \
  tar xzf /tmp/ots.tar.gz -C /var/lib/onetime --strip-components=1 && \
  rm /tmp/ots.tar.gz && \
  cd /var/lib/onetime && \
  bundle install --frozen --deployment --without=dev --gemfile /var/lib/onetime/Gemfile && \
  cp -R etc/* /etc/onetime/

ADD entrypoint.sh /usr/bin/

VOLUME /etc/onetime

EXPOSE 7143/tcp

ENTRYPOINT /usr/bin/entrypoint.sh
