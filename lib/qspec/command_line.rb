require 'rspec'
require 'rspec/core/command_line'
require 'redis'
require 'optparse'

module Qspec
  class CommandLine < ::RSpec::Core::CommandLine
    def initialize(options)
      @rest = parse(options)
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
      @configuration.output_stream ||= out
      @options.configure(@configuration)

      if @qspec_opts[:count]
        start_worker
      else
        process
      end
    end

    def start_worker
      id = rand(10000)
      puts "ID: #{id}"
      register_files(id)
      @qspec_opts[:count].times do |i|
        spawn({ "TEST_ENV_NUMBER" => i == 0 ? '' : (i + 1).to_s },
              @qspec_opts[:command] || "qspec --id #{id} #{@rest.join(' ')}",
              out: '/dev/null')
      end
      exit((Process.waitall.all? { |pid, status| status.exitstatus == 0 }) ? 0 : 1)
    end

    def register_files(id)
      redis = Redis.new
      sort_by_size(@configuration.files_to_run).uniq do |f|
        redis.rpush "to_run_#{id}", f
      end
    end

    # large to small
    def sort_by_size(files)
      files.sort_by { |file| -File.stat(file).size }
    end

    def process
      redis = Redis.new
      failed = false
      id = @qspec_opts[:id]
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
