# syntax=docker/dockerfile:experimental

FROM ruby:2.6.6-alpine3.13

RUN --mount=type=cache,id=apk,target=/var/lib/apk/ apk update

ENV ALPINE_MIRROR "http://dl-cdn.alpinelinux.org/alpine"
RUN \
  --mount=type=cache,id=apk,target=/var/lib/apk/ \
  echo "${ALPINE_MIRROR}/edge/main" >> /etc/apk/repositories \
  && apk add --no-cache nodejs-current --repository="http://dl-cdn.alpinelinux.org/alpine/edge/community"

# Don't inherit local env settings when setting up bundler
RUN unset BUNDLE_PATH
RUN unset BUNDLE_BIN

ENV GEM_HOME "/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

RUN gem install bundler -v 1.3.0
# https://jer-k.github.io/update-gem-dockerfile-alpine-linux
RUN \
  --mount=type=cache,id=apk,target=/var/lib/apk/ \
  apk --update add --virtual run-dependencies \
    build-base \
    postgresql-client \
    postgresql-dev
RUN gem install pg -- --with-pg-lib=/usr/lib

# https://github.com/locomotivecms/wagon/issues/340
WORKDIR /
COPY ./entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3000
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
