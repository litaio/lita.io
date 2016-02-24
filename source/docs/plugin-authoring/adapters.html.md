---
guide: Plugin Authoring
section: Adapters
menu: plugin-authoring
---

An adapter is a plugin that allows Lita to connect to a particular chat service. It's a Ruby class that inherits from `Lita::Adapter` and implements a set of required methods. In this section of the guide, we'll walk through the process of creating a plugin for the fictitious chat service, FancyChat.

### Generating an adapter {#generating}

Start by generating the files for a new plugin by running <kbd>lita adapter <var>NAME_OF_YOUR_ADAPTER</var></kbd>. In this case, the name would be <kbd>fancychat</kbd>. You can type either <kbd>fancychat</kbd> or <kbd>lita-fancychat</kbd>. If you leave off the prefix, Lita will add it for you.

The generator command creates a new directory called `lita-fancychat` with all the files required for a Ruby gem. The adapter class will be defined in the file `lib/lita/adapters/fancychat.rb` and within the `Lita::Adapters` namespace. It's convention for Lita adapters to be in this namespace, but it's not strictly necessary. Any class in any location can serve as an adapter. Notice that the adapter is a class that inherits from `Lita::Adapter` and that the adapter is registered with Lita using the call `Lita.register_adapter(:fancychat, FancyChat)`. The first argument is a Ruby symbol which people will use to configure their Lita instances to use your adapter.

The generator also creates a test file for the adapter at `spec/lita/adapters/fancychat_spec.rb`. Testing is covered later in the guide.

From here on out, it's your job to implement the required methods to make the adapter function!

### Configuration {#configuration}

Adapters will likely require some configuration in order to connect to the chat service, such as a username and password. To set up this configuration, use the class-level `config` method, which defines configuration attributes for the adapter. These attributes will be exposed to users on the `Lita.config.adapters.fancychat` object and they'll set values for them in their `lita_config.rb` file. Let's say Fancychat requires only two attributes to make a connection: username and password. We'll also add one optional attribute that will hold the names of the channels (chat rooms) Lita should join after connecting.

~~~ ruby
module Lita
  module Adapters
    class Fancychat < Adapter
      config :username, type: String, required: true
      config :password, type: String, required: true
      config :channels, type: Array
    end

    Lita.register_adapter(:fancychat, Fancychat)
  end
end
~~~

A user would then configure your adapter like this:

~~~ ruby
Lita.configure do |config|
  config.robot.adapter = :fancychat
  config.adapters.fancychat.username = "litabot"
  config.adapters.fancychat.password = "#n9sd90cs@MKfs"
  config.adapters.fancychat.channels = ["#general", "#engineering"]
end
~~~

The `config` method takes the name of the attribute to create as a Ruby symbol, with a few optional parameters. For full details on using the `config` method, take a look at the [configuration](/plugin-authoring/configuration/) page.

### Required methods {#required-methods}

With configuration out of the way, it's time to implement the required methods for the adapter to actually function. The abstract methods adapters should implement are: *run*, *shut_down*, *send_messages*, *set_topic*, *join*, and *part*.

In some cases, some of these methods may not be applicable to a particular chat service, in which case you can just leave them unimplemented, and plugins that call them will simply cause a warning to Lita's log saying the adapter doesn't implement the method.

{:.spacer}
#### run and shut_down

`run` is the most important method. This is what gets called by Lita when starting up and must establish a connection with the chat service and begin listening for incoming messages. The mechanism by which you do this is entirely up to you, but it's important that you implement some concurrency mechanism (threads, EventMachine, Celluloid, etc.) so that incoming messages can still be processed even while a previous message is still being processed. The `run` method itself should block, since Lita itself doesn't do anything to keep the robot running.

Imagine that Fancychat has its own client library for Ruby that handles concurrency. We can use the client to implement the adapter methods, beginning with run (some boilerplate code removed for brevity):

~~~ ruby
require 'fancychat'

class Fancychat < Adapter
  def initialize(robot)
    super
    @client = ::Fancychat::Client.new(config.username, config.password)
  end

  def run
    @client.on_connect do
      robot.trigger(:connected)

      config.rooms.each { |room| @client.join(room) }
    end

    @client.on_message do |message, user, channel|
      user = Lita::User.find_by_name(user)
      user = Lita::User.create(user) unless user
      source = Lita::Source.new(user: user, room: channel)
      message = Lita::Message.new(robot, message, source)
      robot.receive(message)
    end

    @client.connect
  end

  def shut_down
    @client.disconnect
  end
end
~~~

That's a lot of code! Let's walk through what's happening here:

The Fancychat client library is going to do the heavy lifting for us, so we require it at the top of the file. Because all of the methods in the adapter will need to interface with the Fancychat service in some way, we override the constructor (`initialize`) to create an instance of the Fancychat client library with a username and password. The `config` method is a convenience method to access `Lita.config.adapters.fancychat`, so we can easily get at the values the user set for the configuration attributes we defined.

The `run` method has three responsibilites: Set up a callback to perform some one-time tasks when the connection to Fancychat is established, set up the logic for what to do when a message is received over Fancychat, and finally, connect to Fancychat.

The Fancychat client library provides an `on_connect` method which takes a block and will execute the block as soon as the connection is established. We want two things to happen at this point: we want to trigger a `:connected` event to the entire Lita system (full details about this can be found on the [events](/plugin-authoring/events/) page), and we want Lita to join each of the chat rooms the user specified with the `rooms` configuration attribute.

The Fancychat client library also provides an `on_message` method which allows us to control what will happen when an message is received. The method yields the raw string message, the string username of the person who sent the message, and the string name of the channel it was sent in, if applicable. To dispatch this message to Lita's handler system, we must construct a few objects.

Lita keeps track of users using the `Lita::User` class and automatically saves them in Redis. Most of the time when Lita receives a message, it's from a user Lita has seen before, so we use `Lita::User.find_by_name` to try to find an existing user with that name. If one isn't found, we use the `create` method to initialize and save a new one. In either case, we now have a Lita user object.

Next, we construct a `Lita::Source` object, which represents the person or room where a message originated. Messages will usually always have a user associated with them, whereas the room/channel may be optional if the message was sent directly to Lita privately.

Next, we create a `Lita::Message` object to represent the actual message. This contains a reference to the currently running `Lita::Robot` object, and the message and source objects we just created.

Finally, we pass the message object to the currently running robot using the `receive` method. Lita will take everything from there.

Now that we've set up the behavior for connection and incoming message handling, all run needs to do is actually connect, which is handled by the client library's `connect` method. This will block until it receives a method call telling it to disconnect or the Lita process is sent a signal to interrupt/terminate.

`shut_down` is called automatically when the Lita process is killed. Use it to perform any last minute clean up that might be necessary. In this case, we just call the Fancychat client library's `disconnect` method for a clean shut down. In many cases, the body of the `shut_down` method can be empty, because no clean up is required.

{:.spacer}
#### Other methods

The other methods adapters implement are generally not as complicated as the `run` method. The most important remaining method is `send_messages`, which is the interface other plugins use to send messages out from Lita back to users and chat rooms.

~~~ ruby
class Fancychat < Adapter
  def send_messages(target, messages)
    messages.each do |message|
      @client.send(target.room || target.user, message)
    end
  end
end
~~~

`send_messages` receives a target, which is a `Lita::Source` object designating the desired recipient of the message, and messages, an array of strings to send to the target. In this case, we simply call the Fancychat client library's `send` method with each message, and it handles the details of the network communication.

Setting a chat room's topic message, and making Lita join and part chat rooms on demand are the last bits of functionality adapters can provide. These are generally similar to sending messages, in the sense that you will probably just be delegating to a client library for the chat service, which is what we will do here with Fancychat:

~~~ ruby
class FancyChat < Adapter
  def set_topic(target, topic)
    @client.set_topic(target.source, topic)
  end

  def join(room_id)
    @client.join(room_id)
  end

  def part(room_id)
    @client.part(room_id)
  end
end
~~~

The body of these methods are self-explanatory. With that, our adapter is finished. Let's take a look at it all together:

~~~ ruby
require 'fancychat'

module Lita
  module Adapters
    class Fancychat < Adapter
      config :username, type: String, required: true
      config :password, type: String, required: true
      config :channels, type: Array

      def initialize(robot)
        super
        @client = ::Fancychat::Client.new(config.username, config.password)
      end

      def run
        @client.on_connect do
          robot.trigger(:connected)

          config.rooms.each { |room| @client.join(room) }
        end

        @client.on_message do |message, user, channel|
          user = Lita::User.find_by_name(user)
          user = Lita::User.create(user) unless user
          source = Lita::Source.new(user: user, room: channel)
          message = Lita::Message.new(robot, message, source)
          robot.receive(message)
        end

        @client.connect
      end

      def send_messages(target, messages)
        messages.each do |message|
          @client.send(target.room || target.user, message)
        end
      end

      def shut_down
        @client.disconnect
      end

      def set_topic(target, topic)
        @client.set_topic(target.source, topic)
      end

      def join(room_id)
        @client.join(room_id)
      end

      def part(room_id)
        @client.part(room_id)
      end
    end

    Lita.register_adapter(:fancychat, Fancychat)
  end
end
~~~

### Helper methods {#helper-methods}

Adapters have access to the following helper instance methods:

{:.table .table-bordered}
Name | Description
--- | ---
`robot` | Direct access to the currently running `Lita::Robot` object.
`translate` (aliased to `t`) | A convenience method for easily localizing text. Takes the string key of the translation, and an optional hash of values to interpolate into the translated string. The same method is available at the class level as well.
`config` | The adapter's namespaced configuration object. Equivalent to `robot.config.adapters.your_adapter_namespace`.
`log` | A convenience method for accessing the global logger object. Equivalent to `Lita.logger`.

### Chat-service-specific methods {#chat-service}

The `Lita::Robot` API has methods to cover the lowest common denominator of functionality supported across many different chat services. If you are building an adapter for a chat service that has advanced or non-standard functionality (e.g. attachments on Slack), you should implement `Lita::Adapter#chat_service`. This method should return an object of your choice with methods for accessing these chat-service-specific methods. Plugin authors can access this object by calling `Lita::Robot#chat_service`. Be sure to document any custom methods for your adapter exposed through this interface so users of your adapter know what features are available to them.

### Block syntax {#block-syntax}

If you're just playing around, and don't want to deal with all the boilerplate of a Ruby gem, adapters can also be created by passing a block to `Lita.register_adapter`:

~~~ ruby
Lita.register_adapter(:fancychat) do
  config :username, type: String, required: true
  config :password, type: String, required: true
  config :channels, type: Array

  def initialize(robot)
    super
    @client = ::Fancychat::Client.new(config.username, config.password)
  end

  # etc...
end
~~~

This has the same effect as defining a named class and registering it manually, except that your adapter will be an anonymous class only stored internally in Lita's registry.

For more detailed examples of adapters, check out the built in shell adapter, [lita-hipchat](https://github.com/litaio/lita-hipchat), or [lita-irc](https://github.com/litaio/lita-irc). Refer to Lita's [API documentation](http://rdoc.info/gems/lita/frames) for the exact API adapters must implement.
