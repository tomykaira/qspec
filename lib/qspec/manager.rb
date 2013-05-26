require 'rspec/core/formatters/helpers'

module Qspec
  module Manager
    TIME_LOG_NAME = 'elapsed_time'
    DEFAULT_ELAPSED_TIME = 3.0
    attr_reader :output
    attr_reader :id

    def start_worker
      @id = rand(10000)
      output.puts "ID: #{id}"
      register_files(id)
      if runnning_ports
        puts "Connecting to spork: #{runnning_ports.inspect}"
        runnning_ports.each do |port|
          fork do
            connect_spork(port, id, @configuration.error_stream, output)
          end
        end
      else
        puts "Forking #{@config['workers']} workers"
        command = "qspec #{@options.drb_argv.join " "}"
        @config['workers'].times do |i|
          env = {
            "qspec_id" => id.to_s,
            "TEST_ENV_NUMBER" => i == 0 ? '' : (i + 1).to_s }
          spawn(env,
                command,
                out: '/dev/null')
        end
      end

      @stats = []
      thread = start_progress_thread(id)
      success = Process.waitall.all? { |pid, status| status.exitstatus == 0 }
      thread.exit

      pop_stat(id)

      output.puts "Failures: " if ipc.llen("failure_#{id}") > 0

      each_object("failure_#{id}") do |failure|
        dump_failure(failure)
      end

      log_elapsed_times
      dump_summary
      exit(success ? 0 : 1)
    ensure
      if ipc
        ipc.del("to_run_#{id}")
        ipc.del("stat_#{id}")
        ipc.del("failure_#{id}")
      end
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
      each_object("stat_#{id}") do |obj|
        @stats << obj
        output.print "!!! " if obj[3] > 0
        output.puts obj.inspect
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
      output.puts "\n#{sum[:example]} examples, #{sum[:failure]} failures, #{sum[:pending]} pendings"
    end

    def dump_failure(failure)
      puts ""
      puts failure[:exception]
      failure[:backtrace].each do |line|
        output.puts "\t#{line}"
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
      @sorted_files_to_run ||= if File.exists?(Qspec.path(TIME_LOG_NAME))
                                 sort_by_time(@configuration.files_to_run)
                               else
                                 sort_by_size(@configuration.files_to_run)
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
