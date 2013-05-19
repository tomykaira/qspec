require 'rspec/core/option_parser'

module Qspec
  class Parser < ::RSpec::Core::Parser
    def parser(options)
      parser = super

      parser.separator("\n  **** Qspec ****\n\n")
      parser.on('--id id') do |id|
        options[:id] = id.to_i
      end
      parser.on('--parallel num') do |count|
        options[:count] = count.to_i
      end
      parser.on('--command command') do |command|
        options[:command] = command
      end
      parser.on('--spork') do
        options[:spork] = true
      end

      parser
    end
  end
end
