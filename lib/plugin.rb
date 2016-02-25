class Plugin
  FILE_PATH = File.expand_path('../../data/plugins.json', __FILE__)

  attr_accessor :authors
  attr_accessor :description
  attr_accessor :homepage
  attr_accessor :name
  attr_accessor :plugin_type
  attr_accessor :requirements_list
  attr_accessor :version

  def self.alphabetical_by_group
    load.sort.group_by { |plugin| plugin.plugin_type }
  end

  def initialize(attributes)
    self.authors = attributes['authors']
    self.description = attributes['description']
    self.homepage = attributes['homepage']
    self.name = attributes['name']
    self.plugin_type = attributes['plugin_type']
    self.requirements_list = attributes['requirements_list']
    self.version = attributes['version']
  end

  def <=>(other)
    name <=> other.name
  end

  private

  def self.load
    JSON.load(File.read(FILE_PATH)).map { |attributes| new(attributes) }
  end
end
