---
guide: Getting Started
section: Deployment
menu: getting-started
---

While you can easily run Lita from your own computer, for a more permanent installation you'll want to deploy it to a remote server that stays running all the time.

### Docker {#docker}

It's recommended that you deploy Lita to a server running [Docker](https://www.docker.com/) and [systemd](https://wiki.freedesktop.org/www/Software/systemd/). [CoreOS](https://coreos.com/) is a very good choice for a host operating system with these properties. It can run in the most common cloud computing environments, such as Amazon EC2, Google Cloud Platform, and DigitalOcean.

An official Docker image is provided for Lita. It can be found on the Docker Hub at [litaio/lita](https://hub.docker.com/r/litaio/lita/). Its source code is available on GitHub at [litaio/docker-lita](https://github.com/litaio/docker-lita).

The rest of this section assumes the use of Docker, systemd, and the official Docker image for Lita, but it can be easily adapted to other container runtimes and process management systems.

Note that some commands may require the use of `sudo`, depending on your system.

The only configuration in `lita_config.rb` required for this deployment is the Redis host:

~~~ ruby
Lita.configure do |config|
  config.redis[:host] = "redis"
end
~~~

Add a `Dockerfile` to the root of your Lita instance with the following contents:

~~~ Dockerfile
FROM litaio/lita
~~~

Clone your Lita instance's Git repository on the server where you'll be deploying it. For this guide, we'll clone it to `/var/lita`.

Add a new systemd unit file for Redis at `/etc/systemd/system/redis.service`:

~~~ ini
[Unit]
Description=The Redis data structure server
Requires=docker.service
After=docker.service

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker kill redis
ExecStartPre=-/usr/bin/docker rm redis
ExecStartPre=/usr/bin/docker pull litaio/redis
ExecStart=/usr/bin/docker run --name redis -v /var/lib/redis:/var/lib/redis litaio/redis
ExecStop=/usr/bin/docker stop redis

[Install]
WantedBy=multi-user.target
~~~

If the Docker daemon is not being managed by a systemd service named "docker.service" you should remove the "Requires" and "After" lines. You may also need to change the path to the `docker` executable if it's not located at `/usr/bin/docker`.

Run `systemctl start redis` and `systemctl enable redis` to start the Redis service and ensure that it starts automatically if the machine is rebooted.

Add a new systemd unit file for your Lita instance at `/etc/systemd/system/lita.service`:

~~~ ini
[Unit]
Description=My Lita instance
Requires=docker.service redis.service
After=docker.service redis.service

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker kill lita
ExecStartPre=-/usr/bin/docker rm lita
ExecStart=/usr/bin/docker run --name lita --link redis:redis -v /var/bundle:/var/bundle -p 80:$LITA_HTTP_PORT lita
ExecStop=/usr/bin/docker stop lita

[Install]
WantedBy=multi-user.target
~~~

Replace `$LITA_HTTP_PORT` with whichever port you've configured for your Lita instance's HTTP server (the default is 8080 if you haven't set it explicitly). Change "80" to something else if you want Lita's HTTP server to be exposed on the host machine on a non-standard port.

Again, if the Docker daemon is not being managed by a systemd service named "docker.service" you should remove the "Requires" and "After" lines. Update the path to the `docker` executable if necessary.

To prepare the initial version of your Lita instance:

~~~ bash
cd /var/lita
git pull
docker build -t lita .
~~~

Then run `systemctl start lita` and `systemctl enable lita` to start your Lita instance and ensure that it starts automatically if the machine is rebooted.

Lita is now running. To deploy new versions:


~~~ bash
cd /var/lita
git pull
docker build -t lita .
systemctl restart lita
~~~

As you deploy new versions, your disk will slowly fill with old Docker images. You may want to remove them periodically by running `docker rmi -f dangling=true`.

### Heroku {#heroku}

<div class="alert alert-danger">
  <strong>Warning:</strong>
  Heroku's free tier has traditionally been a popular place to deploy chat bots. However, <a href="https://blog.heroku.com/archives/2015/5/7/new-dyno-types-public-beta">Heroku is changing their pricing</a> and the free tier can no longer be run all the time. If you choose to deploy to Heroku, you'll either need to sign up for a paid plan, or tolerate some Lita downtime every day.
</div>

There are a few things worth mentioning when deploying Lita to Heroku:

1.  Your Procfile should contain one process:

    ~~~
    web: bundle exec lita
    ~~~

1.  To use the Redis To Go add-on and the HTTP port set by Heroku, configure Lita like this:

    ~~~ ruby
    Lita.configure do |config|
      config.redis[:url] = ENV["REDISTOGO_URL"]
      config.http.port = ENV["PORT"]
    end
    ~~~

### Daemonization {#daemonization}

<div class="alert alert-danger">
  <strong>Warning:</strong>
  This feature is deprecated and will be removed in Lita 5.0. Use your operating system's process manager to daemonize Lita instead.
</div>

Lita has built-in support for daemonization on Unix systems. When run as a daemon, Lita will redirect standard output and standard error to a log file, and write the process ID to a PID file. To start Lita as a daemon, run the command: <kbd>lita -d</kbd>.

There are additional command line flags for specifying the path of the log and PID files, which override the defaults. If an existing Lita process is running when <kbd>lita -d</kbd> is invoked, Lita will abort and leave the original process running, unless the <kbd>-k</kbd> flag is specified, in which case it will kill the existing process. Run the command <kbd>lita help</kbd> for information about all the possible command line flags.
