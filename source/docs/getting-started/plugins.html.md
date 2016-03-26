---
guide: User Guide
section: Plugins
menu: getting-started
---

The core Lita gem provides a framework to build on, but includes only a minimal amount of functionality to Lita at runtime. To make real use of it, you'll want to install an adapter plugin to allow Lita to connect to the chat service of your choice, and handler plugins to add new behavior.

The [plugins](https://plugins.lita.io/) page is a catalog of all Lita plugins, both adapters and handlers, that have been published to RubyGems. Use the catalog to find an adapter for the chat service you want to use, and as many handlers as you want for added functionality.

Adding the plugins you choose to Lita is as simple as adding them to the Gemfile and running the <kbd>bundle</kbd> command in your shell to update the Gemfile.lock. The <kbd>bundle</kbd> command comes from Bundler, which is installed alongside Lita.

For example, to run Lita on HipChat with the karma and Google Images handlers, your complete Gemfile would look like this:

~~~ ruby
source "https://rubygems.org"

gem "lita"

gem "lita-hipchat"

gem "lita-karma"
gem "lita-google-images"
~~~

Adapters will likely require some configuration to be able to connect. See the documentation for the adapter for details. Without installing an adapter plugin, you can still use the default shell adapter to chat with Lita in your terminal.
