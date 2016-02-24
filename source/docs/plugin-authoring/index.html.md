---
guide: Plugin Authoring
section: Overview
overview: true
menu: plugin-authoring
---

Lita's plugin system is used to connect with different chat services and to add new runtime behavior. This guide provides details for programmers to create their own plugins. If you're just learning about Lita, you may want to check out the [getting started](/getting-started/) guide first.

Plugins are written in Ruby, so you'll need some familiarity with Ruby and its ecosystem of tools to write and publish a plugin. To test plugins, Lita provides some useful additions for the [RSpec](https://github.com/rspec/rspec) testing framework. It's not necessary to use them, but familiarity with RSpec will be very beneficial in testing your plugins.

### Plugin types {#plugin-types}

Lita supports three types of plugins: adapters, handlers, and extensions. Some of Lita's features are shared between multiple types of plugins, but each type of plugin has its own special purpose.

**Adapters** are the glue between the core Lita framework and a specific chat service such as IRC, HipChat, or Slack. Adapters generally have a set of configuration attributes that the user will set with the details of their account information. Adapters also implement a set of abstract methods to satisfy the basic functionality Lita requires. This includes connecting to the service, sending and receiving messages, joining and parting from chat rooms, setting chat room topics, and shutting down when Lita is asked to disconnect.

**Handlers** add new functionality that users will interface with at runtime. This includes chat routes (Lita's ability to reply to messages with certain patterns) and HTTP routes (for responding to HTTP requests to certain URLs). The behavior of both chat routes and HTTP routes can be arbitrarily complex. You're encouraged to write handlers to make Lita do things that are useful to you. Handlers provide methods to easily define and configure chat and HTTP routes, and various convenience methods for storing data, making HTTP requests, and sending messages back to users or chat rooms.

**Extensions** are a special type of plugin that provide new functionality for developing other plugins and extending the core Lita framework. Extensions achieve this by registering callbacks with various hooks exposed by Lita. Extensions are an advanced topic and in most cases you won't need to write one, though you may find extensions that provide features you'd like to use in your own plugins.

### Plugin loading {#plugin-loading}

Plugins are just Ruby classes that have been added to Lita's plugin registry before the robot starts up. When an adapter plugin is registered, it becomes available to use, but must be specified by name in the user's configuration file for the robot to use it. When a handler or extension is registered, it is always loaded and active when the robot is running.

The recommended way to create a plugin is to use the generator commands that are part of the <kbd>lita</kbd> executable and covered in more detail later in this guide. The generators will create a directory of files that can be published as a gem and loaded via RubyGems and Bundler, which will automatically activate them just by putting them in the user's Gemfile.

If you prefer to keep your own plugins private, and don't want to deal with the extra boilerplate required to maintain each plugin as a separate gem, you can also just require plain Ruby files inside your Lita project directory at the top of the `lita_config.rb` file.

To interact with a plugin locally while developing it, just run Lita from inside the plugin's directory with <kbd>bundle exec lita</kbd>, and the plugin will be loaded into the robot's registry.
