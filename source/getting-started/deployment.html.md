---
guide: Getting Started
section: Deployment
menu: getting-started
---

While you can easily run Lita from your own computer, for a more permanent installation you'll want to deploy it to a remote server. Where you deploy Lita is up to you, but there are a few common patterns for deployment.

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
