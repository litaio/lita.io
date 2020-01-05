FROM ruby:2.7.0

ENV LANG C.UTF-8

VOLUME ["/usr/src/app/build", "/usr/src/app/plugin_data"]

WORKDIR /usr/src/app

RUN bundle config --global frozen 1 &&\
    apt-get update && \
    apt-get -y --no-install-recommends install nodejs python-setuptools python-pip && \
    pip install awscli && \
    apt-get -qy clean autoclean autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

CMD ["./deploy.sh"]
