---
guide: User Guide
section: Configuration
menu: getting-started
---

To configure Lita, edit the file `lita_config.rb` generated by the <kbd>lita new</kbd> command. This is just a plain Ruby file that will be evaluated when Lita is starting up. A Lita config file looks something like this:

~~~ ruby
Lita.configure do |config|
  config.robot.name = "Sir Bottington"
  config.robot.mention_name = "bottington"
  config.robot.alias = "/"
  config.robot.adapter = :example_chat_service
  config.adapters.example_chat_service.username = "bottington"
  config.adapters.example_chat_service.password = "secret"
  config.redis[:host] = "redis.example.com"
  config.handlers.karma.cooldown = 300
  config.handlers.google_images.safe_search = :off
end
~~~

If you want to use a config file with a different name or location, invoke <kbd>lita</kbd> with the <kbd>-c</kbd> option and provide the path to the config file.

The following configuration attributes are available:

{:.table .table-bordered}
Name | Type | Description | Default
--- | --- | --- | ---
`config.robot.name` | `String` | The display name Lita will use on the chat service. | `"Lita"`
`config.robot.mention_name` | `String` | The name Lita will look for in messages to determine if the message is being addressed to it. Usually this is the same as the display name, but in some cases it may not be. For example, in HipChat, display names are required to be a first and last name, such as "Lita Bot", whereas the mention system would use a name like "LitaBot". | `config.robot.name`
`config.robot.alias` | `String` | The alias Lita will look for in messages to determine if the message is being addressed to it. Useful if you want to use something shorter than Lita's name or mention name, such as a slash, to send it a command. | None
`config.robot.adapter` | `Symbol`, `String` | The adapter to use. | `:shell`
`config.robot.default_locale` | `Symbol`, `String` | The locale code for the language Lita's user interface will use. | `I18n.default_locale`
`config.robot.log_level` | `Symbol`, `String` | The severity level of log messages to output. Valid options are, in order of severity: `:debug`, `:info`, `:warn`, `:error`, and `:fatal`. For whichever level you choose, log messages of that severity and greater will be output. | `:info`
`config.robot.log_formatter` | `#call` | A callable object that is used to determine the format for log messages. When called, the object will receive four arguments: severity (the log level), datetime (the timestamp of the message), progname (the name of the program), and msg (the actual message to be logged). It should return a string which will be the final message that is logged. | `->(severity, datetime, progname, msg) { "[#{datetime.utc}] #{severity}: #{msg}\n" }`
`config.robot.admins` | `Array<String>` | An array of string user IDs which will tell Lita which users are considered administrators. Only these users will have access to Lita's "auth" commands. The IDs needed for this attribute can be found using the built-in [user info](/getting-started/usage/#user-info) command. | `nil`
`config.robot.error_handler` | `#call` | A callable object invoked whenever an exception is raised. When called, the object will receive one argument: error (the exception that occurred). | `-> (error) {}`
`config.redis` | `Hash` | Options for the Redis connection. | `{}`
`config.http.host` | `String` | The host Lita's web server will bind to. | `"0.0.0.0"`
`config.http.port` | `Integer`, `String` | The port Lita's web server will listen on. | `8080`
`config.http.min_threads` | `Integer`, `String` | The minimum number of system threads Lita's web server will use. | `0`
`config.http.max_threads` | `Integer`, `String` | The maximum number of system threads Lita's web server will use. The number will vary automatically based on load, but it will never go above this number. | `16`
`config.http.middleware` | `Lita::MiddlewareRegistry` | Rack middleware to be added to the built-in web server. Call `#use` on this object, passing it a Rack middleware class, and any initialization arguments or block the middleware needs. This is identical to the interface of `Rack::Builder#use`. | `Lita::MiddlewareRegistry.new`
`config.adapter` | `Lita::Config` | *Deprecated*: Options for the chosen adapter. Some older adapters may use this instead of `config.adapters`. See the adapter's documentation. | N/A
`config.adapters` | `Object` | Adapters may choose to expose a config object here with their own options. See the adapter's documentation. | N/A
`config.handlers` | `Object` | Handlers may choose to expose a config object here with their own options. See the handler's documentation. | N/A

### Localization {#localization}

Lita is internationalized and can use any localization. Setting your preferred localization is as easy as setting the configuration attribute `config.robot.default_locale` to the preferred language code. If a translation is not available for the selected locale, Lita will fall back to the default locale, which is English. Locales can be specified with an optional territory, and will fall back to the general language if a territory-specific translation is not available.

~~~ ruby
Lita.configure do |config|
  # Tries Mexican Spanish, falling back to Spanish, and then to English.
  config.robot.default_locale = "es-MX"

  # Tries Spanish, falling back to English.
  config.robot.default_locale = "es"
end
~~~

If the environment variable <var>LANG</var> is set, Lita will use its value for setting the locale upon start up. This value is overriden if `config.robot.locale` is set.

Note: Prior to Lita v4.8.0, the locale was set via `config.robot.locale` instead of `config.robot.default_locale`. The latter is preferred because it affects the entire program, whereas the former affects only the current thread. Because incoming messages are dispatched within threads, using `config.robot.locale` would appear not to persist across incoming messages, which could be surprising.
