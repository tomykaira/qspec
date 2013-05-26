require 'yaml'

module Qspec
  class Config
    DEFAULT_PATH = '.qspec.yml'

    def initialize(path = DEFAULT_PATH)
      @path = path
      if File.exists?(path)
        @config = YAML.load_file(path)
      else
        STDERR.puts "You do not have #{path}.  Initialize with `qspec-helper init`"
        exit 1
      end
    end

    def [](key)
      @config[key]
    end

    def self.create_template(path = DEFAULT_PATH)
      if File.exists?(path)
        STDERR.puts "You already have a template file #{path}.  Remove it if you want to reset."
        exit 1
      end
      File.open(path, 'w') do |f|
        f.write <<TMPL
# DO NOT check this file into VCS (e.g. git).
# Parallelization setting differs between machines.
no_gc: false
ipc: file         # 'file' or 'redis', if 'redis', gem and server are required
sort_by: time     # 'time' or 'size',  if 'time', store execution time and use it next time
workers: 4  # half of cpu - number of cpu
TMPL
      end
      puts "Config file created in #{path}. Check it before run `qspec spec`."
    end
  end
end
