---
guide: Plugin Authoring
section: Events
menu: plugin-authoring
---

The `Lita::Robot` object serves as a global event bus in Lita's runtime. Any Lita code can trigger an event on the robot, and handler plugins can define event callbacks which subscribe to those events by name. When an event is triggered, the calling code can pass a payload hash with any arbitrary data it wishes the receiving code to have.

To trigger an event from any Lita code with access to the currently running robot:

~~~ ruby
robot.trigger(:some_event_happened, foo: :bar, baz: :blah)
~~~

See the [handlers guide](/plugin-authoring/handlers/#event-routes) for details on how handlers can subscribe to events.

### Built-in events {#built-in-events}

There are a few events which the core Lita framework triggers:

{:.table .table-bordered}
Name | Description
--- | ---
`:loaded` | Fired when the `Lita::Robot` object has been initialized during start up. This can be used as a hook point for handlers to define routes that depend on user configuration not known until runtime, run migrations on data in Redis, or other start up tasks.
`:shut_down_started` | Fired when the robot first begins shutting down.
`:shut_down_completed` | Fired when the robot has finished shutting down both the built-in web server and the chat adapter.

Adapters are encouraged to trigger a `:connected` event so that other plugins can run set up code that needs to be done at runtime.
