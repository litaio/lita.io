---
guide: Plugin Authoring
section: Handlers
menu: plugin-authoring
---

%p A handler is a plugin that adds new functionality to Lita at runtime. It's a class that inherits from <code>Lita::Handler</code>. There are two primary components to a handler: route definitions, and the route callbacks. There are both chat routes and HTTP routes. There's also an event subscription system available to plugins of all types which work similarly to the other kinds of routes.

%p To create a new handler plugin, generate the initial files by running the following command in your shell: <kbd>lita handler <var>NAME_OF_YOUR_HANDLER</var></kbd> For example, <kbd>lita handler lita-guide-examples</kbd>. You don't need to specify the conventional "lita-" prefix in the name. Lita will add it for you if it's missing.

%p Using the example command above, the generator creates a new directory called <code>lita-guide-examples</code> with all the files required for a Ruby gem. The handler class will be defined in the file <code>lib/lita/handlers/guide_examples.rb</code> and within the <code>Lita::Handlers</code> namespace. It's convention for Lita handlers to be in this namespace, but it's not strictly necessary. Any class in any location can serve as an handler. Notice that the handler is a class that inherits from <code>Lita::Handler</code> and that the handler is registered with Lita using the call <code>Lita.register_handler(GuideExamples)</code>. This adds it to Lita's plugin registry, so that any Lita instance which includes your plugin in its Gemfile will automatically load it.

%p The generator also creates a test file for the handler at <code>spec/lita/handlers/guide_examples_spec.rb</code>. Testing is covered later in the guide.

%p With the plugin files generated, it's time to start adding some routes!

%h3#chat-routes Chat routes

%p A chat route makes Lita listen for messages via chat. To define a chat route, use the class method <code>route</code>:

%pre
  %code.ruby route(/^echo\s+(.+)/, :echo)

%p <code>route</code> takes a regular expression that will be used to determine whether or not an incoming message should trigger the route, and the name of the instance method that should be called when this route is triggered. Only two arguments are required, but <code>route</code> accepts a few additional options:

%table.table.table-bordered
  %tr
    %th Name
    %th Type
    %th Description
    %th Default
  %tr
    %td
      %code :command
    %td Boolean
    %td If set to true, the route will only trigger when "directed" at the robot. Directed means that it's sent via a private message, or the message is prefixed with the bot's name in some form (optionally prefixed with an @, and optionally followed by a colon or comma and white space). This prefix is stripped from the message body itself, but <code>Lita::Message#command?</code> available in handlers can be used if you need to determine whether or not a message was a command after it's been routed.
    %td
      %code false
  %tr
    %td
      %code :restrict_to
    %td <code>Symbol</code>, <code>String</code>, <code>Array&lt;String, Symbol&gt;</code>
    %td Authorization groups necessary to trigger the route. The user sending the message must be a member of at least one of the supplied groups. See <a href="/getting-started/#authorization-groups">authorization groups</a> for more information.
    %td
      %code nil
  %tr
    %td
      %code :help
    %td
      %code Hash&lt;String&gt;
    %td A map of example invocations of the route and descriptions of what they do. These values will be used to generate the listing for the built-in "help" handler. The robot's mention name will automatically be added to the front of the example if the route is a command.
    %td
      %code {}

%p Here is an example of a route declaration with all the possible options:

%pre
  %code.ruby
    :preserve
      route(/^echo\s+(.+)/, :echo, command: true, restrict_to: [:testers, :committers], help: {
        "echo TEXT" => "Replies back with TEXT."
      })

%p Routes will remember aribtrary key/value pairs that are not in the table above. Extra options are accessible by Lita extensions to add custom functionality to the routing system. (More on this later. See: <a href="#extensions">Extensions</a>.)

%p If you like, you can also declare a route without the second argument (the method name) and supply a block that will act as the body of the callback:

%pre
  %code.ruby
    :preserve
      route(/^echo\s+(.+)/) do |response|
        # Callback code goes here
      end

%p Providing the callback inline using a block is primarily a stylistic choice. Using a named instance method  and providing a block both do the same thing. One advantage of separating the route definitions from their callbacks is that multiple routes can share the same callback. Another is that it's easy to look at all of a handler's route definitions to get an idea of what messages it responds to without getting bogged down in the details of their callbacks. Finally, if you use a named instance method, you can unit test the callback independently from the routing system. Lita includes testing tools to make testing chat routes easy, in either case. More on this later.

%h4.spacer Callbacks

%p When a route is triggered, it invokes the instance method specified by the second argument to <code>route</code> (or a block if an inline callback was provided). These methods take one argument, a <code>Lita::Response</code> object. <code>Lita::Response</code> is the primary interface for inspecting details about the incoming message and responding to it. It has the following useful methods:

%table.table.table-bordered
  %tr
    %th Name
    %th Description
  %tr
    %td <code>reply</code>
    %td Sends one or more string messages back to the source of the original message, either a private message or a chat room.
  %tr
    %td <code>reply_privately</code>
    %td Sends one or more string messages back to the user who sent the original message, whether it was initated in a private message or a chat room.
  %tr
    %td <code>matches</code>
    %td An array of regular expression matches obtained via <code>String#scan</code>.
  %tr
    %td <code>match_data</code>
    %td A <code>MatchData</code> object obtained via <code>Regexp#match</code>.
  %tr
    %td <code>args</code>
    %td The user's message as an array of strings, as it would be parsed by <code>Shellwords.split</code>. For example, if the message was "Lita: auth add Joe committers", calling <code>args</code> would return <code>["add", "Joe", "committers"]</code>. ("auth" is considered the command and so is not included in the arguments.) This is very handy for commands that take arguments in a way similar to how a UNIX shell would work.
  %tr
    %td <code>message</code>
    %td A <code>Lita::Message</code> object for the incoming message.
  %tr
    %td <code>user</code>
    %td A <code>Lita::User</code> object for the user who sent the message.
  %tr
    %td <code>extensions</code>
    %td A hash of arbitrary data that can be populated by Lita extensions for custom functionality. (More on this later. See: <a href="#extensions">Extensions</a>.)

%p If a callback method crashes, the backtrace will be output to Lita's log with the <code>:error</code> level, but it will not crash Lita itself.

%h3#http-routes HTTP routes

%p In addition to chat routes, handlers can also define HTTP routes for Lita's built-in web server. This is achieved with the class-level <code>http</code> method. <code>http</code> returns a <code>Lita::HTTPRoute</code> object, which, in turn, has methods to define routes for the most common HTTP methods.

%p In its simplest form, <code>Lita::HTTPRoute</code>'s methods take two arguments: the path for the route, and the name of the instance method in the handler that it will invoke when the route is triggered. The callback can also be supplied as a block instead of passing the name of a method as an argument.

%p The callback method (or block) takes two arguments: a <code>Rack::Request</code> and a <code>Rack::Response</code>. For example:

%pre
  %code.ruby
    :preserve
      http.get "/greet_browser", :greet

      def greet(request, response)
        response.body &lt;&lt; "Hello, \#{request.user_agent}!"
      end

%p The same behavior, but using a block:

%pre
  %code.ruby
    :preserve
      http.get "/greet_browser" do |request, response|
        response.body &lt;&lt; "Hello, \#{request.user_agent}!"
      end

%p As with chat routes, the choice between a named instance method and a block for callbacks is mostly a stylistic one, though the former may carry more advantages.

%p The request object can be used to inspect the details of the incoming HTTP request and the response object is used to determine the status code, HTTP headers, and body that are ultimately returned to the user. <code>Lita::HTTPRoute</code> has methods for the following HTTP verbs, just like <code>get</code>, which is shown in the examples above:

%ul
  %li <code>head</code>
  %li <code>get</code>
  %li <code>post</code>
  %li <code>put</code>
  %li <code>patch</code>
  %li <code>delete</code>
  %li <code>options</code>
  %li <code>link</code>
  %li <code>unlink</code>

%h4.spacer Advanced routing

%p Lita's HTTP router has the ability to define paths with variable segments, if you should need them. A variable segment is denoted by prefixing a word with a colon. The "symbol" will accept any characters in its place, and will assign the actual value to a parameter with the symbol's name in the Rack environment. To illustrate:

%pre
  %code.ruby
    :preserve
      http.get "/builds/:id", :build_info

      def build_info(request, response)
        id = request.env["router.params"][:id]
        build = MyBuildSystem.find(id)
        response.headers["Content-Type"] = "application/json"
        response.write(MultiJson.dump(build))
      end

%p The variable path segment <code>:id</code> allows the route to match <code>GET /builds/1</code>, <code>GET /builds/2</code>, and so on. It's also possible to use a regular expression to constrain the format of the variable segment. This could be useful, for example, to ensure that the route only matches when <code>:id</code> consists of digits.

%pre
  %code.ruby
    :preserve
      http.get "/builds/:id", :build_info, id: %r{\d+}

%p This illustrates the third, optional argument to the routing methods: a hash of variable names to regular expression constraints.

%p The variable constraint feature also allows two otherwise identical path patterns to route to different callbacks. Consider this case:

%pre
  %code.ruby
    :preserve
      http.get "/builds/:id", :build_info, id: %r{\d+}
      http.get "/builds/:id", :named_build_info

%p In this case, a request to <code>GET /builds/1</code> would trigger the first route, while a request to <code>GET /builds/my_first_build</code> would fall through to the second route.

%p Lita's router also supports path globbing, which allows a group of path segments to collapse into a variable array:

%pre
  %code.ruby
    :preserve
      http.get "/hello/*adjectives/world", :glob

      def glob(request, response)
        response.write(request.env["router.params"][:adjectives].join(", "))
      end

%p This would match a request like <code>GET /hello/dark/cruel/world</code>, and write <code>dark, cruel</code> to the response.

%h3#event-routes Event routes

%p Handlers can communicate with each other or respond to arbitrary system events with the built-in pub-sub event system. Subscribe to an event by name, and provide the name of the instance method that should be invoked when the event triggers. Event callback methods are passed a payload hash with any arbitrary data the caller chooses to provide.

%pre
  %code.ruby
    :preserve
      on :connected, :greet

      def greet(payload)
        target = Source.new(room: payload[:room])
        robot.send_message(target, "Hello \#{payload[:room]}!")
      end

%p As with the other types of routes, you can also provide the callback inline with a block:

%pre
  %code.ruby
    :preserve
      on(:connected) do |payload|
        target = Source.new(room: payload[:room])
        robot.send_message(target, "Hello \#{payload[:room]}!")
      end

%p To trigger an event for other code to intercept, call the robot's <code>trigger</code> method and pass it any payload data you want subscribers to receive:

%pre
  %code.ruby robot.trigger(:connected, room: "#litabot")

%p Most adapters will trigger a <code>:connected</code> event when the robot has started and a connection has been established to the chat service. You can use this event to define routes that require configuration that is not known until runtime.

%h3#mixins Mixins

%p Since handler plugins can end up performing a lot of essentially unrelated functions, you may want to split different types of behavior into different classes that only have one type of route in them. You may also want to use inheritance for your own purposes and prefer not to inherit from <code>Lita::Handler</code>. In this case, you can simply extend your class with the appropriate module(s):

%ul
  %li <code>Lita::Handler::ChatRouter</code> for chat routes.
  %li <code>Lita::Handler::HTTPRouter</code> for HTTP routes.
  %li <code>Lita::Handler::EventRouter</code> for event routes.

%p In fact, <code>Lita::Handler</code> is simply an empty class that is extended with all three:

%pre
  %code.ruby
    :preserve
      module Lita
        class Handler
          extend ChatRouter
          extend HTTPRouter
          extend EventRouter
        end
      end

%h3#helper-methods Helper methods

%p Route callbacks of all types have access to the following helper instance methods:

%table.table.table-bordered
  %tr
    %th Name
    %th Description
  %tr
    %td <code>robot</code>
    %td Direct access to the currently running <code>Lita::Robot</code> object.
  %tr
    %td <code>redis</code>
    %td A <code>Redis::Namespace</code> object which provides each handler with its own isolated Redis store, suitable for many data persistence and manipulation tasks. The Redis namespace defaults to a snake-cased version of the handler's class name. You can set it manually with the class-level <code>namespace</code> method.
  %tr
    %td <code>http</code>
    %td A <code>Faraday::Connection</code> object for making HTTP requests. Takes an optional hash of options and optional block which are passed on to <a href="https://github.com/lostisland/faraday">Faraday</a>.
  %tr
    %td <code>translate</code> (aliased to <code>t</code>)
    %td A convenience method for easily localizing text. Takes the string key of the translation, and an optional hash of values to interpolate into the translated string. The same method is available at the class level as well.
  %tr
    %td <code>after</code>, <code>every</code>
    %td Execute code after a delay or at repeated intervals. More on this below.
  %tr
    %td <code>config</code>
    %td The handler's namespaced configuration object. Equivalent to <code>robot.config.handlers.your_handler_namespace</code>.
  %tr
    %td <code>log</code>
    %td A convenience method for accessing the global logger object. Equivalent to <code>Lita.logger</code>.

%h3#timers Timers

%p Handlers can execute blocks of code after a delay, or repeatedly at intervals by using timers. The handler methods <code>after</code> and <code>every</code> perform these two tasks, respectively. Each method takes a number of seconds to wait, and a block to execute after the time has elapsed. They each yield a <code>Lita::Timer</code> object to the block. For recurring timers created with <code>every</code>, you should call <code>stop</code> on the timer object when it reaches a terminating condition, or it will continue forever until Lita is stopped.

%pre
  %code.ruby
    :preserve
      def greet(response)
        after(5) { |timer| response.reply("Hello, 5 seconds later!") }
      end

      def reminder(response)
        every(60) do |timer|
          response.reply("This is your 60 second reminder!")
          timer.stop if some_condition?
        end
      end

%p If you want to use a timer outside a class that inherits from <code>Lita::Handler</code> (where these helper methods aren't available) you can use <code>Lita::Timer</code> directly.

.alert.alert-info
  %strong Note:
  The recurring timer does not start waiting until after the block has executed on subsequent iterations. This means that if your timer interval is 60 seconds, but your block takes 10 seconds to run, the block will only happen every 70 seconds of real time.

%h3#configuration Configuration

%p Often handlers will require some sort of configuration by the user in order to work. For example, the handler might need the user's API key for an external web service. To specify configuration attributes, use the class-level <code>config</code> method:

%pre
  %code.ruby
    :preserve
      module Lita
        module Handlers
          class HandlerWithConfig &lt; Handler
            config :api_key

            route(/call api/, command: true) do |response|
              response.reply(ThirdPartyAPI.new(config.api_key).call)
            end
          end

          Lita.register_handler(HandlerWithConfig)
        end
      end

%p This would expose the configuration attribute at <code>Lita.config.handlers.handler_with_config.api_key</code> and users can set a value for it in their <code>lita_config.rb</code> file. The handler can then use the value the user sets by calling <code>config.api_key</code> in any instance method. The <code>config</code> instance method is a convenience accessor equivalent to <code>robot.config.handlers.your_handler_name</code>.

%p The <code>config</code> class method, shown in the code example above, takes the name of the attribute to create as a Ruby symbol, with a few optional parameters. For full details on using the <code>config</code> method, take a look at the <a href="/plugin-authoring/configuration/">configuration</a> page.

%h3#examples Examples

%p Here is a basic handler which simply echoes back whatever the user says.

%pre
  %code.ruby
    :preserve
      module Lita
        module Handlers
          class Echo &lt; Handler
            route(/^echo\s+(.+)/, :echo, help: { "echo TEXT" => "Echoes back TEXT." })

            def echo(response)
              response.reply(response.matches)
            end
          end

          Lita.register_handler(Echo)
        end
      end

%p Here is a handler that tells a user who their United States congressional representative is based on zip code with data from a fictional HTTP API. The results are saved in the handler's namespaced Redis store to save HTTP calls on future requests.

%pre
  %code.ruby
    :preserve
      module Lita
        module Handlers
          class Representative &lt; Handler
            route(/representative\s+(\d{5})/, :lookup, command: true, help: {
              "representative ZIP_CODE" => "Looks up your U.S. congressional representative by zip code."
            })

            def lookup(response)
              zip = response.matches[0][0]
              rep = redis.get(zip)
              rep = get_rep(zip) unless rep
              response.reply "The representative for \#{zip} is \#{rep}."
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

.alert.alert-info
  %strong Note:
  The <a href="https://github.com/intridea/multi_json">MultiJson</a> library is bundled along with Lita. You should use it for parsing and generating JSON in your plugins.

%p For more detailed examples, check out the built in authorization, help, and web handlers, or any of the many existing handler plugins on the <a href="https://www.lita.io/plugins">plugins</a> page. Refer to the <a href="http://rdoc.info/gems/lita/frames">API documentation</a> for exact specifications for handlers' methods.
