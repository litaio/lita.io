$:.unshift File.expand_path("../lib", __FILE__)
require 'fileutils'
require 'plugin_updater'

task :update_plugins do
  plugin_data_path = './plugin_data'
  FileUtils.mkdir_p(plugin_data_path) unless File.directory?(plugin_data_path)
  PluginUpdater.update
end

task :default => [:update_plugins]
