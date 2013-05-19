require 'rspec'
require 'rspec/core/command_line'
require 'rspec/core/formatters/helpers'
require 'qspec/manager'
require 'qspec/spork_helper'
require 'redis'
require 'optparse'

module Qspec
  class CommandLine < ::RSpec::Core::CommandLine
    include Manager # defines start_worker
    include SporkHelper
    attr_reader :output, :redis

    def initialize(options)
      @rest = parse(options)
      @redis = Redis.new
      assert_option_combination
      super(@rest.dup)
    end

    def parse(options)
      @qspec_opts = {}
      opts = OptionParser.new
      opts.on('--id id') do |id|
        @qspec_opts[:id] = id.to_i
      end
      opts.on('--parallel num') do |count|
        @qspec_opts[:count] = count.to_i
      end
      opts.on('--command command') do |command|
        @qspec_opts[:command] = command
      end
      opts.on('--spork') do
        @qspec_opts[:spork] = true
      end

      opts.parse!(options)
    end

    def assert_option_combination
      if @qspec_opts[:count] && @qspec_opts[:id] ||
          @qspec_opts[:count].nil? && @qspec_opts[:id].nil?
        raise ArgumentError.new("Specify one of --id or --parallel")
      end
    end

    def run(err, out)
      @configuration.error_stream = err
      @output = @configuration.output_stream ||= out
      @options.configure(@configuration)

      if @qspec_opts[:spork]
        start_spork_workers
      elsif @qspec_opts[:count] || @options.options[:drb]
        start_worker
      else
        process
      end
    end

    def process
      success = true
      id = @qspec_opts[:id]
      while f = redis.lpop("to_run_#{id}")
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
          @configuration.formatters.clear
          @world.example_groups.clear
        end
      end
      success ? 0 : @configuration.failure_exit_code
    end
  end
end
