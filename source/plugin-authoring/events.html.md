---
guide: Plugin Authoring
section: Events
menu: plugin-authoring
---

%p The <code>Lita::Robot</code> object serves as a global event bus in Lita's runtime. Any Lita code can trigger an event on the robot, and handler plugins can define event callbacks which subscribe to those events by name. When an event is triggered, the calling code can pass a payload hash with any arbitrary data it wishes the receiving code to have.

%p To trigger an event from any Lita code with access to the currently running robot:

%pre
  %code.ruby robot.trigger(:some_event_happened, foo: :bar, baz: :blah)

%p See the <a href="/plugin-authoring/handlers/#event-routes">handlers guide</a> for details on how handlers can subscribe to events.

%h3#built-in-events Built-in events

%p There are a few events which the core Lita framework triggers:

%table.table.table-bordered
  %tr
    %th Name
    %th Description
  %tr
    %td
      %code :loaded
    %td Fired when the <code>Lita::Robot</code> object has been initialized during start up. This can be used as a hook point for handlers to define routes that depend on user configuration not known until runtime, run migrations on data in Redis, or other start up tasks.
  %tr
    %td
      %code :shut_down_started
    %td Fired when the robot first begins shutting down.
  %tr
    %td
      %code :shut_down_completed
    %td Fired when the robot has finished shutting down both the built-in web server and the chat adapter.

%p Adapters are encouraged to trigger a <code>:connected</code> event so that other plugins can run set up code that needs to be done at runtime.
