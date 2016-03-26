---
guide: Plugin Authoring Guide
section: Localization
menu: plugin-authoring
---

Lita is internationalized, and you're encouraged to extract all language-specific strings into a locale file instead of hardcoding them into your Ruby code. Plugins created with Lita's generator make this very easy to do. In the root of your plugin's directory, you will find a `locales` directory with an `en.yml` file. Inside that file, you'll see [YAML](http://www.yaml.org/) like this:

~~~
en:
  lita:
    handlers:
      your_handler_name:
~~~

If your plugin is an adapter or extension, it will instead be under the `adapters` or `extensions`namespace, respectively. Language strings should be inserted as key/value pairs under your plugin's namespace in the YAML file. These keys can then be translated at runtime by using the `translate` method (aliased to `t`) available at both the class and instance level inside your adapter or handler. If we take a look at the route example from before:

~~~ ruby
route(/^echo\s+(.+)/, :echo, command: true, restrict_to: [:testers, :committers], help: {
  "echo TEXT" => "Replies back with TEXT."
})
~~~

An internationalized version of this would look like this:

~~~ ruby
route(/^echo\s+(.+)/, :echo, command: true, restrict_to: [:testers, :committers], help: {
  t("help.echo_key") => t("help.echo_value")
})
~~~

With `en.yml` filled in accordingly:

~~~
en:
  lita:
    handlers:
      your_handler_name:
        help:
          echo_key: echo FOO
          echo_value: Replies back with FOO.
~~~

Note that the period in the translation's key represents a nested level in the YAML file.

If you need to translate a string in an object that doesn't inherit from `Lita::Adapter` or `Lita::Handler` (and therefore doesn't include the `translate` method), you should use `I18n.translate` and pass it the full key, e.g. `"lita.handlers.your_handler_name.help.echo_key"`.

If you need to interpolate values into the string when it's translated, you can pass an optional hash of variable keys and values to the `translate` method:

~~~ ruby
translate("greet", name: user.name)
~~~

~~~
en:
  lita:
    handlers:
      your_handler_name:
        greet: "Hello, %{name}!"
~~~

The `%{}` syntax in the YAML interpolates the variable with the given name.

To add additional localizations for your plugin, create additional YAML files in the `locales` directory, using the locale code for the language. Any file ending in `.yml` will be loaded by Lita. The contents of each locale file should have the same structure of keys, except the very top key should be the locale code, and of course, all the values should be written in the given language.
