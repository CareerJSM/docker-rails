FROM ruby:2.6.6-alpine3.13

ENV NODE_VERSION 14.16.0-r0
RUN \
  apk add --update nodejs=${NODE_VERSION} npm=${NODE_VERSION} \
  && npm install --global yarn

# Don't inherit local env settings when setting up bundler
RUN unset BUNDLE_PATH
RUN unset BUNDLE_BIN

ENV GEM_HOME "/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

RUN mkdir -p ${GEM_HOME} \
  && gem install bundler -v 1.3.0
# https://jer-k.github.io/update-gem-dockerfile-alpine-linux
RUN \
  apk --update add --virtual run-dependencies \
    build-base \
    postgresql-client \
    postgresql-dev
RUN gem install pg -- --with-pg-lib=/usr/lib

# Upgrade to security issues
RUN apk add python3=3.8.8-r0

EXPOSE 3000
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
