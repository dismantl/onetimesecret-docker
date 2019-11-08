# onetimesecret-docker

A dockerized version of [One-Time Secret](https://github.com/onetimesecret/onetimesecret), so you can easily host your secrets yourself or quickly spin up a microservice. The Dockerfile downloads and runs the latest 0.10.x release of OTS. The recommended way to run this image in production is using [docker-compose](https://docs.docker.com/compose/), as described below.

## How to run this image
The quick-and-dirty way:

```
docker run --name ots -p "7143:7143" dismantl/onetimesecret
```

You'll then be able to visit your instance of OTS by visiting https://localhost:7143.

## Customization

The best way to run a customized instance of onetimesecret-docker is using docker-compose with the provided `docker-compose.yml`:

```
version: '2'
services:
  onetimesecret:
    container_name: ots
    image: 'dismantl/onetimesecret'
    ports:
      - '7143:7143'
    volumes:
      - './config:/etc/onetime/config'
      - './redis.conf:/etc/onetime/redis.conf'
    environment:
      - OTS_NAME=John Doe
```

Here you can customize the name used in the email templates using the `OTS_NAME` environment variable. For additional customization, provide your own version of [any of the web or email templates](https://github.com/onetimesecret/onetimesecret/tree/master/templates) and include them as [mounted volumes](https://docs.docker.com/storage/volumes/) in the `docker-compose.yml` file.

You can also provide your own version of the OTS `config` and Redis `redis.conf` files if you desire, as demonstrated in the example above.

## Persistence
If you would like to host a production instance of onetimesecret-docker or migrate from one host to another, you'll need to consider the persistence of any data (secrets) stored by the service. Unopened secrets (e.g. secrets whose one-time links have not yet been opened) are stored in Redis, so you'll want to use a mounted volume for the Redis data directory (`/var/lib/onetime/redis` as configured in the provided `redis.conf.example` and `docker-compose.yml`) so the data will be saved on the docker host. In addition you'll need to keep the OTS instance-specific secret, which is listed in the OTS `config` file and automatically generated on first run:

```
:site:
  :host: localhost:7143
  :domain: localhost
  :ssl: false
  # NOTE Once the secret is set, do not change it (keep a backup offsite)
  :secret: f8e1c604d5cf6ff9281d8814ab01ea7385f1364a
:redis:
  :uri: 'redis://user:713f4350e4858f3da82c64452ac571d80c685cee@127.0.0.1:7179/0?timeout=10&thread_safe=false&logging=false'
  :config: /etc/onetime/redis.conf
...
```

You can then provide this secret to the image by supplying it as the `OTS_SECRET` environment variable. The following `docker-compose.yml` demonstrates providing an OTS secret and a persistent Redis data directory:

```
version: '2'
services:
  onetimesecret:
    container_name: ots
    image: 'dismantl/onetimesecret'
    restart: always
    ports:
      - '7143:7143'
    volumes:
      - './config:/etc/onetime/config'
      - './redis.conf:/etc/onetime/redis.conf'
      - './redis:/var/lib/onetime/redis'
    environment:
      - OTS_NAME=John Doe
      - OTS_SECRET=f8e1c604d5cf6ff9281d8814ab01ea7385f1364a
```

(Note that if you leave the default Redis password `CHANGEME` in `redis.conf` and `config`, a unique password will be generated and stored in the config files. This password does not need to be persisted.)

## Security
This image is not built with strong security requirements. The image downloads and executes the latest version of OTS from Github, so this essentially relies on the security of TLS and [Wget](https://www.gnu.org/software/wget/)'s certificate checking to prevent your image from downloading and executing potentially malicious code. This image also provides no guarantee about the security of the Onetimesecret software. Don't use it for super sensitive stuff, but it's still better than emailing your plaintext passwords to people...

## Licensing
Inspired by the courage of open source leaders like [Coraline Ada Ehmke](https://www.wired.com/story/open-source-license-requires-users-do-no-harm/) and [Seth Vargo](https://www.wired.com/story/software-company-chef-wont-renew-ice-contact/), this software is licensed under the [Hippocratic License](https://firstdonoharm.dev/). Any organizations or companies that act as or cooperate with law enforcement (such as police departments and ICE) are specifically forbidden from using this software.
