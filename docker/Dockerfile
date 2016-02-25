FROM litaio/ruby

RUN apt-get update && \
    apt-get -y --no-install-recommends install nodejs python-pip && \
    pip install awscli && \
    gem install bundler && \
    apt-get -qy clean autoclean autoremove && \
    rm -rf /var/lib/apt/lists/*

CMD ["/app/deploy.sh"]
WORKDIR /app
