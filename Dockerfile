FROM ubuntu:20.04

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install RVM & Ruby
# https://github.com/rvm/ubuntu_rvm
RUN \
  apt-get update \
  && apt-get install -y software-properties-common \
  && apt-add-repository -y ppa:rael-gc/rvm \
  && apt-get update \
  && apt-get install -y rvm \
  && apt-get autoremove && apt-get autoclean && apt-get clean \
  # && usermod -a -G rvm $(whoami) \
  && source ~/.bashrc
RUN /usr/share/rvm/bin/rvm user gemsets && /usr/share/rvm/bin/rvm install 2.6.5

RUN ln -s /usr/share/rvm/rubies/ruby-2.6.5/bin/ruby /usr/bin/ruby
RUN ruby -v
RUN ln -s /usr/share/rvm/rubies/ruby-2.6.5/bin/gem /usr/bin/gem
RUN gem install executable-hooks -v ">=1.3.2" && gem regenerate_binstubs
RUN gem -v

# https://stackoverflow.com/questions/25899912/how-to-install-nvm-in-docker
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION v12.8.1
RUN mkdir $NVM_DIR \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
  && source $NVM_DIR/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default \
  && source ~/.bashrc
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN ln -s /usr/local/nvm/versions/node/$NODE_VERSION/bin/node /usr/bin/node
RUN ln -s /usr/local/nvm/versions/node/$NODE_VERSION/bin/npm /usr/bin/npm
RUN node -v

# https://classic.yarnpkg.com/en/docs/install#debian-stable
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install -yqq --no-install-recommends yarn

# Don't inherit local env settings when setting up bundler
RUN unset BUNDLE_PATH
RUN unset BUNDLE_BIN

ENV GEM_HOME "/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

RUN gem install bundler -v 1.3.0
# https://stackoverflow.com/questions/3116015/how-to-install-postgresqls-pg-gem-on-ubuntu#3116128
RUN \
  apt-get install -y libpq-dev \
  && gem install pg -- --with-pg-lib=/usr/lib

# https://github.com/locomotivecms/wagon/issues/340
WORKDIR /
COPY ./entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3000
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
