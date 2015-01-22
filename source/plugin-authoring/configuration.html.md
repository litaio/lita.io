---
guide: Plugin Authoring
section: Configuration
menu: plugin-authoring
---

%p Adapters and handlers share a common system for specifying configuration attributes. These attributes are exposed to users on the main <code>Lita.config</code> object and can be used to change the behavior or specify data that a plugin should use at runtime. Configuration attributes are automatically namespaced with the plugin's type and "namespace" value. For example, configuration attributes defined by an adapter called <code>Fancychat</code> would be found at <code>Lita.config.adapters.fancychat</code> and configuration attributes defined by a handler named <code>GuideExamples</code> would be found at <code>Lita.config.handlers.guide_examples</code>.

%p If you're writing a plugin that's significantly complex, and you want to separate it into multiple classes, you can force the different classes to share the same configuration attribute and namespaced data store in Redis by using the class-level <code>namespace</code> method, providing a string namespace:

%pre
  %code.ruby
    :preserve
      class MyPluginExtraClass &lt; Lita::Handler
        namespace "my_plugin"
      end

%p If you use the block form for defining a plugin, the namespace is determined by the first argument to the registration method:

%pre
  %code.ruby
    :preserve
      Lita.register_handler(:my_plugin) do
        # ...
      end

%p Configuration attributes themselves are defined using the class-level <code>config</code> method. This method takes one mandatory argument, a Ruby symbol that will serve as the name of the attribute.

%pre
  %code.ruby
    :preserve
      class MyPlugin &lt; Lita::Handler
        config :api_key
      end

%p The above code would create an attribute at <code>Lita.config.handlers.my_plugin.api_key</code>. Each attribute must be defined with a separate call to <code>config</code>. The <code>config</code> method takes several options which provide additional control over the attribute:

%table.table.table-bordered
  %tr
    %th Name
    %th Type
    %th Description
  %tr
    %td
      %code :type
    %td Any object
    %td Specifies a requirement that the value provided by the user must be of the given data type. If it isn't, Lita will abort with an error message during start up.
  %tr
    %td
      %code :types
    %td
      %code Array
    %td The same as <code>:type</code>, but used to specify that the value can be any of the types in the array. <code>:type</code> and <code>:types</code> actually both accept either one type or an array of types, so use whichever option name you think reads better.
  %tr
    %td
      %code :required
    %td Boolean
    %td Whether or not the attribute must be specified by the user. If a required attribute is not given a value, Lita will abort with an error message during start up.
  %tr
    %td
      %code :default
    %td Any object
    %td The initial value of the attribute. If a value is not given using this option, the attribute's initial value will be <code>nil</code>.

%p Configuration attributes can also be nested infinitely deep. If you want an attribute to have sub-attributes, pass <code>config</code> a block and call the method again inside the block:

%pre
  %code.ruby
    :preserve
      class MyPlugin &lt; Lita::Handler
        config :api_credentials do
          config :username, type: String
          config :password, type: String
        end

%p This will generate two attributes, both of which must be strings: <code>Lita.config.handlers.my_plugin.api_credentials.username</code> and <code>Lita.config.handlers.my_plugin.api_credentials.password</code>. If a configuration attribute has any child attributes, it will become a "container" object, and any options provided in defining the parent attribute will not have any effect.

%p In addition to type checking, you can also specify your own validation for a configuration attribute. Within the block passed to the <code>config</code> method, call the <code>validate</code> method. <code>validate</code> yields the attribute's value to a block. If the block returns a non-<code>nil</code> value, the attribute will fail validation and Lita will abort, using the block's return value as the reason. Here is an example:

%pre
  %code.ruby
    :preserve
      class MyPlugin &lt; Lita::Handler
        config :api_token do
          validate do |value|
            "must be 10 characters" unless value.respond_to?(:size) && value.size == 10
          end
        end
      end

%p Validation for nested attributes works in the same way.

.alert.alert-warning
  %strong Important!
  All the values in <code>Lita.config</code> are frozen at runtime. Consider them read only and wrap them with accessor methods in your plugins if you need their raw values to be manipulated in some way.

