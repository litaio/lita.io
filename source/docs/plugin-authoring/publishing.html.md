---
guide: Plugin Authoring Guide
section: Publishing
menu: plugin-authoring
---

When you're finished writing your plugin, you are encouraged to publish it publicly. This allows other Lita users to take advantage of your work and will cause it to appear in the catalog on the [plugins](https://plugins.lita.io/) page.

If you used one of Lita's generator commands to create the files for your plugin initially, then most of the work is done for you. Here's a checklist of things to go over before publication:

*   Fill in all the sections of the README file that are marked as TODO.
*   Make sure the gemspec file has all fields filled in, including the description, summary, and homepage. Double check that your contact information is correct in the authors and email fields.
*   To have your plugin's type (adapter or handler) included in its information on the [plugins](https://plugins.lita.io/) page, make sure the metadata field in the gemspec is set correctly. It should look like this:

    ~~~ ruby
    spec.metadata = { "lita_plugin_type" => "handler" }
    ~~~

    Substitute "adapter" as the value for adapter plugins and "extension" as the value for extension plugins.

Once you've gone through the checklist, you just need to build a gem and push it to RubyGems. Conveniently, Bundler will handle this for you with one simple shell command:

~~~
rake release
~~~

Note that this will require you to log into an account on [RubyGems](https://rubygems.org/) if you're not already authenticated.
