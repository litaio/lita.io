---
guide: Getting Started
section: Overview
overview: true
menu: getting-started
---

**Lita** is a [chat bot](https://en.wikipedia.org/wiki/Chatterbot) written in [Ruby](https://www.ruby-lang.org/) with persistent storage provided by [Redis](http://redis.io/). It uses a plugin system to connect to different chat services and to provide new behavior. The plugin system uses the familiar tools of the Ruby ecosystem: [RubyGems](https://rubygems.org/) and [Bundler](http://bundler.io/).

<h3 id="features">Features</h3>

* Can connect to any chat service
* Simple installation and setup
* Easily extendable with plugins
* Data persistence with Redis
* Built-in web server and routing
* Event system for behavior triggered in response to arbitrary events
* Support for outgoing HTTP requests
* Group-based authorization
* Internationalization
* Configurable logging
* Generators for creating new plugins

<h3 id="coming-from-hubot">Coming from Hubot</h3>

Lita draws much inspiration from GitHub's fantastic [Hubot](https://hubot.github.com/), but has a few key differences and strengths:

* It's written in Ruby.
* It exposes the full power of Redis rather than using it to serialize JSON.
* It's easy to develop and test plugins for with the provided [RSpec](https://github.com/rspec/rspec) extras. Lita strongly encourages thorough testing of plugins.
* It uses the Ruby ecosystem's standard tools (RubyGems and Bundler) for plugin installation and loading.
