---
guide: Plugin Authoring
section: Configuration
menu: plugin-authoring
---

Adapters and handlers share a common system for specifying configuration attributes. These attributes are exposed to users on the main `Lita.config` object and can be used to change the behavior or specify data that a plugin should use at runtime. Configuration attributes are automatically namespaced with the plugin's type and "namespace" value. For example, configuration attributes defined by an adapter called `Fancychat` would be found at `Lita.config.adapters.fancychat` and configuration attributes defined by a handler named `GuideExamples` would be found at `Lita.config.handlers.guide_examples`.

If you're writing a plugin that's significantly complex, and you want to separate it into multiple classes, you can force the different classes to share the same configuration attribute and namespaced data store in Redis by using the class-level `namespace` method, providing a string namespace:

~~~ ruby
class MyPluginExtraClass < Lita::Handler
  namespace "my_plugin"
end
~~~

If you use the block form for defining a plugin, the namespace is determined by the first argument to the registration method:

~~~ ruby
Lita.register_handler(:my_plugin) do
  # ...
end
~~~

Configuration attributes themselves are defined using the class-level `config` method. This method takes one mandatory argument, a Ruby symbol that will serve as the name of the attribute.

~~~ ruby
class MyPlugin < Lita::Handler
  config :api_key
end
~~~

The above code would create an attribute at `Lita.config.handlers.my_plugin.api_key`. Each attribute must be defined with a separate call to `config`. The `config` method takes several options which provide additional control over the attribute:

{:.table .table-bordered}
Name | Type | Description
--- | --- | ---
`:type` | `Object` | Specifies a requirement that the value provided by the user must be of the given data type. If it isn't, Lita will abort with an error message during start up.
`:types` | `Array` | The same as `:type`, but used to specify that the value can be any of the types in the array. `:type` and `:types` actually both accept either one type or an array of types, so use whichever option name you think reads better.
`:required` | Boolean | Whether or not the attribute must be specified by the user. If a required attribute is not given a value, Lita will abort with an error message during start up.
`:default` | `Object` | The initial value of the attribute. If a value is not given using this option, the attribute's initial value will be `nil`.

Configuration attributes can also be nested infinitely deep. If you want an attribute to have sub-attributes, pass `config` a block and call the method again inside the block:

~~~ ruby
class MyPlugin < Lita::Handler
  config :api_credentials do
    config :username, type: String
    config :password, type: String
  end
end
~~~

This will generate two attributes, both of which must be strings: `Lita.config.handlers.my_plugin.api_credentials.username` and `Lita.config.handlers.my_plugin.api_credentials.password`. If a configuration attribute has any child attributes, it will become a "container" object, and any options provided in defining the parent attribute will not have any effect.

In addition to type checking, you can also specify your own validation for a configuration attribute. Within the block passed to the `config` method, call the `validate` method. `validate` yields the attribute's value to a block. If the block returns a non-`nil` value, the attribute will fail validation and Lita will abort, using the block's return value as the reason. Here is an example:

~~~ ruby
class MyPlugin < Lita::Handler
  config :api_token do
    validate do |value|
      "must be 10 characters" unless value.respond_to?(:size) && value.size == 10
    end
  end
end
~~~

Validation for nested attributes works in the same way.

<div class="alert alert-warning">
  <strong>Important!</strong>
  All the values in <code>Lita.config</code> are frozen at runtime. Consider them read only and wrap them with accessor methods in your plugins if you need their raw values to be manipulated in some way.
</div>
