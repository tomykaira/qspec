require 'rspec/core/command_line'

module Qspec
  class CommandLine < ::RSpec::Core::CommandLine
    include Manager # defines start_worker
    include SporkHelper
    attr_reader :output, :ipc, :config, :id

    def initialize(options)
      @config = Config.new()
      @ipc = IPC.from_config(@config)
      @id = ENV['qspec_id']

      super(options)
    end

    def run(err, out)
      @configuration.error_stream = err
      @output = @configuration.output_stream ||= out
      @options.configure(@configuration)

      if @id
        process
      else
        start_worker
      end
    end

    def process
      success = true
      while f = ipc.lpop("to_run_#{id}")
        @configuration.add_formatter(Qspec::Formatters::RedisFormatterFactory.build(id, f))
        begin
          load File.expand_path(f)
          @configuration.reporter.report(@world.example_count, @configuration.randomize? ? @configuration.seed : nil) do |reporter|
            begin
              GC.disable if @config['no_gc']
              @configuration.run_hook(:before, :suite)
              success &&= @world.example_groups.ordered.all? {|g| g.run(reporter)}
            ensure
              @configuration.run_hook(:after, :suite)
              GC.enable if @config['no_gc']
              GC.start  if @config['no_gc']
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
