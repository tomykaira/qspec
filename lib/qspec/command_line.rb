require 'parallel'
module Qspec
  class CommandLine
    TIME_LOG_NAME = 'elapsed_time'
    DEFAULT_ELAPSED_TIME = 3.0
    attr_reader :ipc, :config, :id

    def initialize(args)
      @config = Config.new()
      @ipc = IPC.from_config(@config)
      @id = rand(10000)
      @stats = []
      @rspec_options = RSpec::Core::ConfigurationOptions.new(args)
      @rspec_configuration = RSpec.configuration
      @rspec_options.configure(@rspec_configuration)
    end

    def run(err, out)
      @rspec_configuration.error_stream = err
      @rspec_configuration.output_stream = out if @rspec_configuration.output_stream == $stdout

      out.puts "ID: #{id}"
      register_files(id)
      puts "Forking #{@config['workers']} workers"

      thread = start_progress_thread(id)
      results = Parallel.map(1..@config['workers'], in_processes: @config['workers']) do |no|
        ENV['TEST_ENV_NUMBER'] = no == 1 ? '' : no.to_s
        process
      end
      thread.exit

      pop_stat(id)

      @rspec_configuration.output_stream.puts "Failures: " if ipc.llen("failure_#{id}") > 0

      each_object("failure_#{id}") do |failure|
        dump_failure(failure)
      end

      log_elapsed_times
      dump_summary
      exit(results.all? ? 0 : 1)
    ensure
      if ipc
        ipc.del("to_run_#{id}")
        ipc.del("stat_#{id}")
        ipc.del("failure_#{id}")
      end
    end

    def process
      ipc = IPC.from_config(@config)
      success = true
      while f = ipc.lpop("to_run_#{id}")
        @rspec_configuration.add_formatter(Qspec::Formatters::RedisFormatterFactory.build(id, f))

        require File.expand_path(f)
        world = RSpec.world
        example_groups = world.ordered_example_groups

        begin
          @rspec_configuration.reporter.report(world.example_count(example_groups)) do |reporter|
            @rspec_configuration.with_suite_hooks do
              success = example_groups.map { |g| g.run(reporter) }.all? && success
            end
          end
        ensure
          world.example_groups.clear
          @rspec_configuration.reset # formatter, reporter
        end
      end
      success
    end

    private
    def start_progress_thread(id)
      Thread.new do
        loop do
          pop_stat(id)
          sleep 1
        end
      end
    end

    def pop_stat(id)
      o = @rspec_configuration.output_stream
      each_object("stat_#{id}") do |obj|
        @stats << obj
        o.print "!!! " if obj[3] > 0
        o.puts obj.inspect
      end
    end

    def each_object(key)
      while data = ipc.lpop(key)
        yield(Marshal.load(data))
      end
    end

    def dump_summary
      sum = @stats.each_with_object({ example: 0, failure: 0, pending: 0 }) do |stat, sum|
        sum[:example] += stat[2]
        sum[:failure] += stat[3]
        sum[:pending] += stat[4]
      end
      @rspec_configuration.output_stream.puts "\n#{sum[:example]} examples, #{sum[:failure]} failures, #{sum[:pending]} pendings"
    end

    def dump_failure(failure)
      @rspec_configuration.output_stream.puts ""
      @rspec_configuration.output_stream.puts failure[:exception]
      failure[:backtrace].each do |line|
        @rspec_configuration.output_stream.puts "\t#{line}"
      end
    end

    def log_elapsed_times
      File.open(Qspec.path(TIME_LOG_NAME), 'w') do |f|
        @stats.each do |stat|
          f.puts "#{File.expand_path(stat[0])}:#{stat[1].to_f}"
        end
      end
    end

    def register_files(id)
      sorted_files_to_run.uniq.each do |f|
        ipc.rpush "to_run_#{id}", f
      end
    end

    def sorted_files_to_run
      @sorted_files_to_run ||= if @config['sort_by'] == 'time' && File.exists?(Qspec.path(TIME_LOG_NAME))
                                 sort_by_time(@rspec_configuration.files_to_run)
                               else
                                 sort_by_size(@rspec_configuration.files_to_run)
                               end
    end

    def sort_by_time(files)
      log = Hash[File.readlines(Qspec.path(TIME_LOG_NAME)).map { |line| line.strip.split(":") }]
      files.sort_by { |file| log[File.expand_path(file)].to_f || DEFAULT_ELAPSED_TIME }.reverse
    end

    # large to small
    def sort_by_size(files)
      files.sort_by { |file| -File.stat(file).size }
    end
  end
end
