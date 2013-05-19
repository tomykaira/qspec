require 'rspec/core/drb_options'
require 'rspec/core/configuration_options'

# Override parsers
module Qspec
  class ConfigurationOptions < ::RSpec::Core::ConfigurationOptions
    def env_options
      ENV["SPEC_OPTS"] ? ::Qspec::Parser.parse!(Shellwords.split(ENV["SPEC_OPTS"])) : {}
    end

    def command_line_options
      @command_line_options ||= ::Qspec::Parser.parse!(@args).merge :files_or_directories_to_run => @args
    end

    def options_from(path)
      ::Qspec::Parser.parse(args_from_options_file(path))
    end
  end
end
