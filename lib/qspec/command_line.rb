require 'rspec/core'
require 'rspec/core/command_line'

module Qspec
  class CommandLine < ::RSpec::Core::CommandLine
    include Manager # defines start_worker
    include SporkHelper
    attr_reader :output, :ipc

    def initialize(options)
      @ipc = IPC.available_instance

      options = ::Qspec::ConfigurationOptions.new(options)
      options.parse_options
      super(options)
    end

    def run(err, out)
      @configuration.error_stream = err
      @output = @configuration.output_stream ||= out
      @options.configure(@configuration)

      if @options.options[:spork]
        start_spork_workers
      elsif @options.options[:count] || @options.options[:drb]
        start_worker
      else
        process
      end
    end

    def process
      GC.disable if @options.options[:nogc]

      success = true
      id = @options.options[:id]
      while f = ipc.lpop("to_run_#{id}")
        @configuration.add_formatter(Qspec::Formatters::RedisFormatterFactory.build(id, f))
        begin
          load File.expand_path(f)
          @configuration.reporter.report(@world.example_count, @configuration.randomize? ? @configuration.seed : nil) do |reporter|
            begin
              @configuration.run_hook(:before, :suite)
              success &&= @world.example_groups.ordered.all? {|g| g.run(reporter)}
            ensure
              @configuration.run_hook(:after, :suite)
            end
          end
        ensure
          @world.example_groups.clear
          @configuration.reset # formatter, reporter
        end
      end
      success ? 0 : @configuration.failure_exit_code
    end
  end
end
