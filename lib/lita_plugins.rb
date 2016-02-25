require_relative 'plugin'

class LitaPlugins < ::Middleman::Extension
  attr_reader :lita_plugins

  expose_to_application lita_plugins: :lita_plugins
  expose_to_template  lita_plugins: :lita_plugins

  def initialize(app, options_hash = {})
    super

    @lita_plugins = Plugin.alphabetical_by_group
  end
end

::Middleman::Extensions.register(:lita_plugins, LitaPlugins)
