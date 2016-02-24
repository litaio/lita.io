---
guide: Plugin Authoring
section: Testing
menu: plugin-authoring
---

It's a core philosophy of Lita that any plugins you write for your robot should be as thoroughly tested as any other program you would write. To make this easier, Lita ships with some handy extras for [RSpec](https://github.com/rspec/rspec) that make testing a plugin dead simple. Since Lita plugins are just Ruby code, they can be tested with any framework you like, but RSpec is recommended for its expressiveness and powerful features.

### Setup {#setup}

If you created your plugin with the built-in generator, the files necessary for your RSpec test suite will already be in place in the `spec` directory. If you're building your plugin manually, you only need to require your plugin and Lita's RSpec extras before writing your tests. It's recommended that you put this in `spec/spec_helper.rb` and then simply require "spec_helper" in each spec file.

~~~ ruby
require "lita-your-plugin"
require "lita/rspec"
~~~

### Testing adapters and extensions {#testing-adapters}

To include some helpful setup for testing Lita code, require "lita/rspec", then add `lita: true` to the metadata for an example group.
Adapters and extensions should be unit tested as you would any other Ruby code. For a few workflow improvements, activate `Lita::RSpec` by passing `:lita` as RSpec metadata on your plugin's example group:

~~~ ruby
describe Lita::Adapters::MyAdapter, lita: true do
  describe "#run" do
    # ...
  end

  # ...
end
~~~

Turning on `Lita::RSpec` will have the following effects:

* All Redis interaction will be namespaced to a test environment and automatically cleared out before each example.
* Lita's logger is stubbed to prevent log messages from cluttering up your test output.
* A brand new `Lita::Registry` is created for each test and made accessible via the `registry` method. The registry is used to hold global state such as all the plugins Lita knows about and the user configuration.

The first two points you don't really have to think about. The third one you will likely interact with directly. To create an instance of an adapter, you must pass a `Lita::Robot` as an argument. The robot, in turn, takes a registry as an argument. Your set up code will end looking something like this:

~~~ ruby
describe Lita::Adapters::MyAdapter, lita: true do
  let(:robot) { Lita::Robot.new(registry) }
  subject { described_class.new(robot) }
end
~~~

At this point you'll have a functioning instance of your adapter as the test subject and can proceed normally.

### Testing handlers {#testing-handlers}

The setup for testing a handler is similar, but use `:lita_handler` as metadata instead.

~~~ ruby
describe Lita::Handlers::MyHandler, lita_handler: true do
  # ...
end
~~~

This will have the following effects, in addition to the effects of the `lita: true` metadata hook:

* Your handler will automatically be added to the registry before each example.
* Strings sent with `Lita::Robot#send_messages` will be pushed to an array accessible as `replies` so you can make expectations about output from the robot.
* You have access to the following cached objects set with `let`:
  * `robot` – a `Lita::Robot`
  * `source` – a `Lita::Source`, the source of the incoming message
  * `user` – a `Lita::User`, the user who sent the message, attached to the source

  Note that these objects are instances of the real classes and not test doubles.

If you need to register additional handlers, for cases when functionality is divided or shared across multiple classes, you can use the `:additional_lita_handlers` metadata hook:

~~~ ruby
describe Lita::Handlers::MyHandler, lita_handler: true, additional_lita_handlers: SharedConfig do
  # ...
end
~~~

This will register both `MyHandler` and `SharedConfig` for each example. The value of `:additional_lita_handlers` can be a single object or an array of objects.

#### Testing routes {#testing-routes}

You can test routes of all types very easily using these RSpec matchers:

~~~ ruby
# Chat routes
it { is_expected.to route("some message") }
it { is_expected.to route("some message").to(:some_callback) }
it { is_expected.to route_command("some command") }
it { is_expected.to route_command("some command").to(:some_other_callback) }
it { is_expected.to route("secret").with_authorization_for(:secret_admins).to(:secret_callback) }

# HTTP routes
it { is_expected.to route_http(:get, "/foo") }
it { is_expected.to route_http(:get, "/foo").to(:some_http_callback) }

# Event routes
it { is_expected.to route_event(:some_event) }
it { is_expected.to route_event(:some_event).to(:some_event_callback) }
~~~

Matchers with a fluent (chained) interface make the expectation more specific. If the name of a route is not specified, RSpec will only verify that the message, HTTP request, or event routes to *any* callback. The `with_authorization_for` method is necessary to verify routes that are restricted to certain authorization groups.

Each of these matchers can be turned into a negative expectation by writing `is_expected.not_to` instead of `is_expected.to`. The matchers themselves are the same in both positive and negative forms.

<div class="alert alert-info">
  <strong>Note:</strong>
  As always, be careful when making negative message expectations, as a route might fail to match for a reason other than why you think. Positive message expectations are always preferred when possible.
</div>

#### Testing behavior {#testing-behavior}

Since the behavioral logic in handlers are just regular instance methods (unless you use the defined callbacks with a block), you can unit test them just as you would any other methods in a Ruby class. However, if you prefer more of an integration testing approach, there are some helper methods available to assist with this.

To send a message to the robot, use `send_message` and `send_command`. Then set expectations about the contents of the `replies` array.

~~~ ruby
it "lets everyone know when someone is happy" do
  send_message("I'm happy!")
  expect(replies.last).to eq("Hey, everyone! #{user.name} is happy! Isn't that nice?")
end

it "greets anyone that says hi to it" do
  send_command("hi")
  expect(replies.last).to eq("Hello, #{user.name}!")
end
~~~

If you want to send a message or command from a user other than the default test user (which is set up for you with `let(:user)` automatically by `Lita::RSpec`), you can invoke either method with the `:as` option, supplying a `Lita::User` object.

~~~ ruby
it "lets everyone know that Carl is happy" do
  carl = Lita::User.create(123, name: "Carl")
  send_message("I'm happy!", as: carl)
  expect(replies.last).to eq("Hey, everyone! Carl is happy! Isn't that nice?")
end
~~~

You can also specify that a message came from a certain chat room with the `:from` option and a `Lita::Room` object.

~~~ ruby
it "replies with the room the message came from" do
  send_message("Where am I?", from: Lita::Room.create("#lita.io"))
  expect(replies.last).to eq("You are chatting in #lita.io!")
end
~~~

To test the behavior of an HTTP route callback, use the `http` method. This method returns a `Faraday::Connection` object. Call one of the standard HTTP verb methods on this object to make an HTTP request and return a response. Then you can set expectations about the response.

~~~ ruby
describe "#foo" do
  it "writes 'bar' to the page" do
    response = http.get("/foo")
    expect(response.body).to eq("bar")
  end
end
~~~

<div class="alert alert-info">
  <strong>Note:</strong>
  The <code>http</code> method requires that the <code>rack-test</code> gem be part of your bundle, either in the Gemfile or set as a development dependency in your plugin's gemspec.
</div>
