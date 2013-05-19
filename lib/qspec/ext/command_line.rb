require 'rspec'
require 'rspec/core/command_line'
require 'redis'

module RSpec
  module Core
    class CommandLine
      def initialize(options, configuration=RSpec::configuration, world=RSpec::world)
        if Array === options
          if i = options.index('--qspec-id')
            @qspec_id = options[i + 1].to_i
            options.delete_at(i); options.delete_at(i + 1)
          end
          options = ConfigurationOptions.new(options)
          options.parse_options
        end
        @options       = options
        @configuration = configuration
        @world         = world
      end

      alias_method :run_original, :run

      # Configures and runs a suite
      #
      # @param [IO] err
      # @param [IO] out
      def run(err, out)
        if @qspec_id
          run_queue(err, out)
        else
          run_original(err, out)
        end
      end

      # Run tests in the queue
      #
      # @param [IO] err
      # @param [IO] out
      def run_queue(err, out)
        @configuration.error_stream = err
        @configuration.output_stream ||= out
        @options.configure(@configuration)

        redis = Redis.new
        failed = false
        id = @qspec_id
        while f = redis.lpop("to_run_#{id}")
          begin
            load File.expand_path(f)
            @configuration.reporter.report(@world.example_count, @configuration.randomize? ? @configuration.seed : nil) do |reporter|
              begin
                @configuration.run_hook(:before, :suite)
                if @world.example_groups.ordered.all? {|g| g.run(reporter)}
                  redis.rpush("result_#{id}", 'success')
                else
                  redis.rpush("result_#{id}", 'failure')
                  failed = true
                end
              ensure
                @configuration.run_hook(:after, :suite)
              end
            end
          ensure
            @world.example_groups.clear
          end
        end
        failed ? @configuration.failure_exit_code : 0
      end
    end
  end
end
