require 'rspec/core/option_parser'

module Qspec
  class Parser < ::RSpec::Core::Parser
    def parser(options)
      parser = super

      parser.separator("\n  **** Qspec ****\n\n")

      parser
    end
  end
end
