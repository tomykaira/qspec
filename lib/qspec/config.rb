require 'yaml'

module Qspec
  class Config
    def initialize(path = '.qspec.yml')
      @path = path
      @config = File.exists?(path) && YAML.load_file(path)
    end

    def [](key)
      @config[key]
    end

    def create_template
      if File.exists?(@path)
        STDERR.puts "You already have a template file #{@path}.  Remove it if you want to reset."
        exit 1
      end
      File.open(@path, 'w') do |f|
        f.write <<TMPL
# DO NOT check this file into VCS (e.g. git).
# Parallelization setting differs between machines.
no_gc: false
ipc: file         # 'file' or 'redis', if 'redis', gem and server are required
workers: 4  # half of cpu - number of cpu
TMPL
      end
    end
  end
end
