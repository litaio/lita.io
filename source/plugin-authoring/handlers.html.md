---
guide: Plugin Authoring
section: Handlers
menu: plugin-authoring
---

A handler is a plugin that adds new functionality to Lita at runtime. It's a class that inherits from `Lita::Handler`. There are two primary components to a handler: route definitions, and the route callbacks. There are both chat routes and HTTP routes. There's also an event subscription system available to plugins of all types which work similarly to the other kinds of routes.

To create a new handler plugin, generate the initial files by running the following command in your shell: <kbd>lita handler <var>NAME_OF_YOUR_HANDLER</var></kbd> For example, <kbd>lita handler lita-guide-examples</kbd>. You don't need to specify the conventional "lita-" prefix in the name. Lita will add it for you if it's missing.

Using the example command above, the generator creates a new directory called `lita-guide-examples` with all the files required for a Ruby gem. The handler class will be defined in the file `lib/lita/handlers/guide_examples.rb` and within the `Lita::Handlers` namespace. It's convention for Lita handlers to be in this namespace, but it's not strictly necessary. Any class in any location can serve as an handler. Notice that the handler is a class that inherits from `Lita::Handler` and that the handler is registered with Lita using the call `Lita.register_handler(GuideExamples)`. This adds it to Lita's plugin registry, so that any Lita instance which includes your plugin in its Gemfile will automatically load it.

The generator also creates a test file for the handler at `spec/lita/handlers/guide_examples_spec.rb`. Testing is covered later in the guide.

With the plugin files generated, it's time to start adding some routes!

### Chat routes {#chat-routes}

A chat route makes Lita listen for messages via chat. To define a chat route, use the class method `route`:

~~~ ruby
route(/^echo\s+(.+)/, :echo)
~~~

`route` takes a regular expression that will be used to determine whether or not an incoming message should trigger the route, and the name of the instance method that should be called when this route is triggered. Only two arguments are required, but `route` accepts a few additional options:

{:.table .table-bordered}
Name | Type | Description | Default
--- | --- | --- | ---
`:command` | Boolean | If set to true, the route will only trigger when "directed" at the robot. Directed means that it's sent via a private message, or the message is prefixed with the bot's name in some form (optionally prefixed with an @, and optionally followed by a colon or comma and white space). This prefix is stripped from the message body itself, but `Lita::Message#command?` available in handlers can be used if you need to determine whether or not a message was a command after it's been routed. | `false`
`:restrict_to` | `Symbol`, `String`, `Array<String, Symbol>` | Authorization groups necessary to trigger the route. The user sending the message must be a member of at least one of the supplied groups. See [authorization groups](/getting-started/usage/#authorization-groups) for more information. | `nil`
`:help` | `Hash<String>` | A map of example invocations of the route and descriptions of what they do. These values will be used to generate the listing for the built-in "help" handler. The robot's mention name will automatically be added to the front of the example if the route is a command. | `{}`

Here is an example of a route declaration with all the possible options:

~~~ ruby
route(/^echo\s+(.+)/, :echo, command: true, restrict_to: [:testers, :committers], help: {
  "echo TEXT" => "Replies back with TEXT."
})
~~~

Routes will remember aribtrary key/value pairs that are not in the table above. Extra options are accessible by Lita extensions to add custom functionality to the routing system. (More on this later. See: [Extensions](/plugin-authoring/extensions/).)

If you like, you can also declare a route without the second argument (the method name) and supply a block that will act as the body of the callback:

~~~ ruby
route(/^echo\s+(.+)/) do |response|
  # Callback code goes here
end
~~~

Providing the callback inline using a block is primarily a stylistic choice. Using a named instance method  and providing a block both do the same thing. One advantage of separating the route definitions from their callbacks is that multiple routes can share the same callback. Another is that it's easy to look at all of a handler's route definitions to get an idea of what messages it responds to without getting bogged down in the details of their callbacks. Finally, if you use a named instance method, you can unit test the callback independently from the routing system. Lita includes testing tools to make testing chat routes easy, in either case. More on this later.

{:.spacer}
#### Callbacks

When a route is triggered, it invokes the instance method specified by the second argument to `route` (or a block if an inline callback was provided). These methods take one argument, a `Lita::Response` object. `Lita::Response` is the primary interface for inspecting details about the incoming message and responding to it. It has the following useful methods:

{:.table .table-bordered}
Name | Description
--- | ---
`reply` | Sends one or more string messages back to the source of the original message, either a private message or a chat room.
`reply_privately` | Sends one or more string messages back to the user who sent the original message, whether it was initated in a private message or a chat room.
`matches` | An array of regular expression matches obtained via `String#scan`.
`match_data` | A `MatchData` object obtained via `Regexp#match`.
`args` | The user's message as an array of strings, as it would be parsed by `Shellwords.split`. For example, if the message was "Lita: auth add Joe committers", calling `args` would return `["add", "Joe", "committers"]`. ("auth" is considered the command and so is not included in the arguments.) This is very handy for commands that take arguments in a way similar to how a UNIX shell would work.
`message` | A `Lita::Message` object for the incoming message.
`user` | A `Lita::User` object for the user who sent the message.
`extensions` | A hash of arbitrary data that can be populated by Lita extensions for custom functionality. (More on this later. See: [Extensions](/plugin-authoring/extensions/).)

If a callback method crashes, the backtrace will be output to Lita's log with the `:error` level, but it will not crash Lita itself.

### HTTP routes {#http-routes}

In addition to chat routes, handlers can also define HTTP routes for Lita's built-in web server. This is achieved with the class-level `http` method. `http` returns a `Lita::HTTPRoute` object, which, in turn, has methods to define routes for the most common HTTP methods.

In its simplest form, `Lita::HTTPRoute`'s methods take two arguments: the path for the route, and the name of the instance method in the handler that it will invoke when the route is triggered. The callback can also be supplied as a block instead of passing the name of a method as an argument.

The callback method (or block) takes two arguments: a `Rack::Request` and a `Rack::Response`. For example:

~~~ ruby
http.get "/greet_browser", :greet

def greet(request, response)
  response.body << "Hello, #{request.user_agent}!"
end
~~~

The same behavior, but using a block:

~~~ ruby
http.get "/greet_browser" do |request, response|
  response.body << "Hello, #{request.user_agent}!"
end
~~~

As with chat routes, the choice between a named instance method and a block for callbacks is mostly a stylistic one, though the former may carry more advantages.

The request object can be used to inspect the details of the incoming HTTP request and the response object is used to determine the status code, HTTP headers, and body that are ultimately returned to the user. `Lita::HTTPRoute` has methods for the following HTTP verbs, just like `get`, which is shown in the examples above:

* `head`
* `get`
* `post`
* `put`
* `patch`
* `delete`
* `options`
* `link`
* `unlink`

{:.spacer}
#### Advanced routing

Lita's HTTP router has the ability to define paths with variable segments, if you should need them. A variable segment is denoted by prefixing a word with a colon. The "symbol" will accept any characters in its place, and will assign the actual value to a parameter with the symbol's name in the Rack environment. To illustrate:

~~~ ruby
http.get "/builds/:id", :build_info

def build_info(request, response)
  id = request.env["router.params"][:id]
  build = MyBuildSystem.find(id)
  response.headers["Content-Type"] = "application/json"
  response.write(MultiJson.dump(build))
end
~~~

The variable path segment `:id` allows the route to match `GET /builds/1`, `GET /builds/2`, and so on. It's also possible to use a regular expression to constrain the format of the variable segment. This could be useful, for example, to ensure that the route only matches when `:id` consists of digits.

~~~ ruby
http.get "/builds/:id", :build_info, id: %r{\d+}
~~~

This illustrates the third, optional argument to the routing methods: a hash of variable names to regular expression constraints.

The variable constraint feature also allows two otherwise identical path patterns to route to different callbacks. Consider this case:

~~~ ruby
http.get "/builds/:id", :build_info, id: %r{\d+}
http.get "/builds/:id", :named_build_info
~~~

In this case, a request to `GET /builds/1` would trigger the first route, while a request to `GET /builds/my_first_build` would fall through to the second route.

Lita's router also supports path globbing, which allows a group of path segments to collapse into a variable array:

~~~
http.get "/hello/*adjectives/world", :glob

def glob(request, response)
  response.write(request.env["router.params"][:adjectives].join(", "))
end
~~~

This would match a request like `GET /hello/dark/cruel/world`, and write `dark, cruel` to the response.

### Event routes {#event-routes}

Handlers can communicate with each other or respond to arbitrary system events with the built-in pub-sub event system. Subscribe to an event by name, and provide the name of the instance method that should be invoked when the event triggers. Event callback methods are passed a payload hash with any arbitrary data the caller chooses to provide.

~~~ ruby
on :connected, :greet

def greet(payload)
  target = Source.new(room: payload[:room])
  robot.send_message(target, "Hello #{payload[:room]}!")
end
~~~

As with the other types of routes, you can also provide the callback inline with a block:

~~~ ruby
on(:connected) do |payload|
  target = Source.new(room: payload[:room])
  robot.send_message(target, "Hello #{payload[:room]}!")
end
~~~

To trigger an event for other code to intercept, call the robot's `trigger` method and pass it any payload data you want subscribers to receive:

~~~ ruby
robot.trigger(:connected, room: "#litabot")
~~~

Most adapters will trigger a `:connected` event when the robot has started and a connection has been established to the chat service. You can use this event to define routes that require configuration that is not known until runtime.

### Mixins {#mixins}

Since handler plugins can end up performing a lot of essentially unrelated functions, you may want to split different types of behavior into different classes that only have one type of route in them. You may also want to use inheritance for your own purposes and prefer not to inherit from `Lita::Handler`. In this case, you can simply extend your class with the appropriate module(s):

* `Lita::Handler::ChatRouter` for chat routes.
* `Lita::Handler::HTTPRouter` for HTTP routes.
* `Lita::Handler::EventRouter` for event routes.

In fact, `Lita::Handler` is simply an empty class that is extended with all three:

~~~ ruby
module Lita
  class Handler
    extend ChatRouter
    extend HTTPRouter
    extend EventRouter
  end
end
~~~

### Helper methods {#helper-methods}

Route callbacks of all types have access to the following helper instance methods:

{:.table .table-bordered}
Name | Description
--- | ---
`robot` | Direct access to the currently running `Lita::Robot` object.
`redis` | A `Redis::Namespace` object which provides each handler with its own isolated Redis store, suitable for many data persistence and manipulation tasks. The Redis namespace defaults to a snake-cased version of the handler's class name. You can set it manually with the class-level `namespace` method.
`http` | A `Faraday::Connection` object for making HTTP requests. Takes an optional hash of options and optional block which are passed on to [Faraday](https://github.com/lostisland/faraday).
`translate` (aliased to `t`) | A convenience method for easily localizing text. Takes the string key of the translation, and an optional hash of values to interpolate into the translated string. The same method is available at the class level as well.
`after`, `every` | Execute code after a delay or at repeated intervals. More on this below.
`config` | The handler's namespaced configuration object. Equivalent to `robot.config.handlers.your_handler_namespace`.
`log` | A convenience method for accessing the global logger object. Equivalent to `Lita.logger`.

### Timers {#timers}

Handlers can execute blocks of code after a delay, or repeatedly at intervals by using timers. The handler methods `after` and `every` perform these two tasks, respectively. Each method takes a number of seconds to wait, and a block to execute after the time has elapsed. They each yield a `Lita::Timer` object to the block. For recurring timers created with `every`, you should call `stop` on the timer object when it reaches a terminating condition, or it will continue forever until Lita is stopped.

~~~ ruby
def greet(response)
  after(5) { |timer| response.reply("Hello, 5 seconds later!") }
end

def reminder(response)
  every(60) do |timer|
    response.reply("This is your 60 second reminder!")
    timer.stop if some_condition?
  end
end
~~~

If you want to use a timer outside a class that inherits from `Lita::Handler` (where these helper methods aren't available) you can use `Lita::Timer` directly.

<div class="alert alert-info">
  <strong>Note:</strong>
  The recurring timer does not start waiting until after the block has executed on subsequent iterations. This means that if your timer interval is 60 seconds, but your block takes 10 seconds to run, the block will only happen every 70 seconds of real time.
</div>

### Configuration {#configuration}

Often handlers will require some sort of configuration by the user in order to work. For example, the handler might need the user's API key for an external web service. To specify configuration attributes, use the class-level `config` method:

~~~ ruby
module Lita
  module Handlers
    class HandlerWithConfig < Handler
      config :api_key

      route(/call api/, command: true) do |response|
        response.reply(ThirdPartyAPI.new(config.api_key).call)
      end
    end

    Lita.register_handler(HandlerWithConfig)
  end
end
~~~

This would expose the configuration attribute at `Lita.config.handlers.handler_with_config.api_key` and users can set a value for it in their `lita_config.rb` file. The handler can then use the value the user sets by calling `config.api_key` in any instance method. The `config` instance method is a convenience accessor equivalent to `robot.config.handlers.your_handler_name`.

The `config` class method, shown in the code example above, takes the name of the attribute to create as a Ruby symbol, with a few optional parameters. For full details on using the `config` method, take a look at the [configuration](/plugin-authoring/configuration/) page.

### Templates {#templates}

If you want to take advantage of a specific chat service's message formatting, such as bold, colors, or monospaced fonts, you can use Lita's template feature. Templates allow you to put the body of a message response in a separate template file. You can have multiple templates with the same template name, and Lita will automatically pick the appropriate file for the current adapter at runtime. If you're using adapter-specific templates, you should also have a generic fallback template that will be used when an adapter you don't explicitly support is used.

Template files should be placed in the `templates` directory at the root of your plugin. If you generated your plugin with a version of Lita prior to 4.2.0, you'll need to create this directory yourself. Template files are given a unique name and the `erb` extension. For example, `example.erb`. To create an adapter-specific version of the same template, include the name of the adapter (as it is specified in `config.robot.adapter`) as the first file extension. For an IRC-specific template, you would name the file `example.irc.erb`. This will be selected when Lita is running with the IRC adapter. Otherwise, the generic `example.erb` will be selected. You can have as many different adapter-specific versions for the same template as you'd like. For example, you could have `example.irc.erb`, `example.hipchat.erb`, `example.slack.erb`, and the fallback `example.erb`.

In order to render a template for an outgoing message, you use the handler's `render_template` method, passing it the name of the template:

~~~ ruby
module Lita
  module Handlers
    module HandlerWithTemplates < Handler
      route(/example/i, command: true) do |response|
        response.reply(render_template("example"))
      end
    end
  end
end
~~~

If we have two template files, `example.irc.erb` and `example.erb` with these contents:

~~~
/me provides an example.
~~~

~~~
Here is an example.
~~~

Then on IRC, the interaction would look like this:

~~~
 You: Lita, example
Lita provides an example.
~~~

And on any other chat service, it would look like this:

~~~
 You: Lita, example
Lita: Here is an example.
~~~

You should always include a generic version of the template. If you try to render a template that doesn't exist, your handler will crash.

Because templates are written in the ERB format, they also support interpolation of variables. The second argument to `render_template` is a hash of variable name and variable value pairs. Each pair provided will create an instance variable of the given name with the given value that is accessible inside the template. For example, if we had a template named `greet.erb` with these contents:

~~~ erb
Hello, <%= @name %>!
~~~

And we rendered the template like this:

~~~ ruby
response.reply(render_template("greet", name: "Carl"))
~~~

The output to the chat would look like this:

~~~
Hello, Carl!
~~~

You also have the option of adding your own helper methods to the template by using the `render_template_with_helpers` method. This version takes an extra argument, an array of Ruby modules, and makes all instance methods in them available to the template being rendered. For example, if you have a template like this:

~~~ erb
<%= reverse_name(@first, @last) %>
~~~

And render the template with this code:

~~~ ruby
helper = Module.new do
  def reverse_name(first, last)
    "#{last}, #{first}"
  end
end

response.reply(render_template("name", [helper], first: "Carl", last: "Pug"))
~~~

The output to the chat would look like this:

~~~
Pug, Carl
~~~

For more information about the ERB format, consult Ruby's standard library documentation or check out [An Introduction to ERB Templating](http://www.stuartellis.eu/articles/erb/).

In order to use the `render_template` or `render_template_with_helpers` methods, the handler must have its `template_root` set to the file path of the templates directory. If you generated your handler with Lita 4.2.0 or greater, this is done for you automatically. Otherwise, you'll need to set it yourself like this:

~~~ ruby
module Lita
  module Handlers
    class HandlerWithTemplates < Handler
      template_root File.expand_path("../../../../templates", __FILE__)
    end
  end
end
~~~

Calling `render_template` or `render_template_with_helpers` without setting the template root will cause your handler to crash.

### Chat-service-specific methods {#chat-service}

If templates are not enough to fully grasp the power of the chat services you want to support, you can also use any additional methods exposed through `Lita::Robot#chat_service`. The return value of this method is `nil` by default, but some adapters may return a custom object with methods providing access to functionality specific to that chat service. A good example of this is the ability to post "attachments" in Slack – a concept not shared across all chat services and hence not supported directly by the `Lita::Robot` API. Since chat service methods are specific to the chat service, you'll need to consult the documentation for the adapters you want to support to see if and how they implement this.

To actually take advantage of chat-service-specific methods, you should take an approach similar to templates by providing fallback behavior for when your plugin is used with a chat service you're not explicitly providing behavior for. You can use the value of `robot.config.robot.adapter` to determine which adapter is in use. (Note that within a handler, `robot.config` is a different value that `config`. The former is the top-level configuration object and the latter is the configuration for the current handler.)

~~~ ruby
case robot.config.robot.adapter
when :slack
  robot.chat_service.send_attachment(target, attachment)
when :fancy_chat
  robot.chat_service.upload_file(file)
else
  robot.send_message(target, message)
end
~~~

### Examples {#examples}

Here is a basic handler which simply echoes back whatever the user says.

~~~ ruby
module Lita
  module Handlers
    class Echo < Handler
      route(/^echo\s+(.+)/, :echo, help: { "echo TEXT" => "Echoes back TEXT." })

      def echo(response)
        response.reply(response.matches)
      end
    end

    Lita.register_handler(Echo)
  end
end
~~~

Here is a handler that tells a user who their United States congressional representative is based on zip code with data from a fictional HTTP API. The results are saved in the handler's namespaced Redis store to save HTTP calls on future requests.

~~~ ruby
module Lita
  module Handlers
    class Representative < Handler
      route(/representative\s+(\d{5})/, :lookup, command: true, help: {
        "representative ZIP_CODE" => "Looks up your U.S. congressional representative by zip code."
      })

      def lookup(response)
        zip = response.matches[0][0]
        rep = redis.get(zip)
        rep = get_rep(zip) unless rep
        response.reply "The representative for #{zip} is #{rep}."
      end

      private

      def get_rep(zip)
        http_response = http.get(
          "http://www.example.com/api/represenative",
          zip_code: zip
        )

        data = MultiJson.load(http_response.body)
        rep = data["representative"]["name"]
        redis.set(zip, rep)
        rep
      end
    end

    Lita.register_handler(Representative)
  end
end
~~~

<div class="alert alert-info">
  <strong>Note</strong>
  The <a href="https://github.com/intridea/multi_json">MultiJson</a> library is bundled along with Lita. You may use it for parsing and generating JSON in your plugins.
</div>

For more detailed examples, check out the built in authorization, help, and web handlers, or any of the many existing handler plugins on the [plugins](https://www.lita.io/plugins) page. Refer to Lita's [API documentation](http://rdoc.info/gems/lita/frames) for the exact specifications of handlers' methods.
