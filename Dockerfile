FROM litaio/ruby

RUN apt-get update && \
    apt-get -y install python-pip && \
    pip install awscli && \
    apt-get -qy clean autoclean autoremove && \
    rm -rf /var/lib/apt/lists/*

CMD ["/app/deploy.sh"]
WORKDIR /app
