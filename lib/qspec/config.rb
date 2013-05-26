require 'yaml'

module Qspec
  class Config
    def initialize(path = '.qspec.yml')
      @config = File.exists?(path) && YAML.load_file(path)
    end

    def [](key)
      @config[key]
    end
  end
end
