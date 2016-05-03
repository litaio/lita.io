require 'fileutils'
require_relative 'lib/plugin_updater'

desc 'Update plugins dataset'
task :update_plugins do
  plugin_data_path = './plugin_data'
  FileUtils.mkdir_p(plugin_data_path) unless File.directory?(plugin_data_path)
  PluginUpdater.update
end

task :default => [:update_plugins]
