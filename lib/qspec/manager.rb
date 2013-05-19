module Qspec
  module Manager
    attr_reader :output

    def start_worker
      id = rand(10000)
      output.puts "ID: #{id}"
      register_files(redis, id)
      if runnning_ports
        puts "Connecting to spork: #{runnning_ports.inspect}"
        runnning_ports.each do |port|
          fork do
            connect_spork(port, id, @configuration.error_stream, output)
          end
        end
      else
        @options.options[:count].times do |i|
          spawn({ "TEST_ENV_NUMBER" => i == 0 ? '' : (i + 1).to_s },
                @options.options[:command] || "qspec --id #{id}",
                out: '/dev/null')
        end
      end

      thread = start_progress_thread(id)
      success = Process.waitall.all? { |pid, status| status.exitstatus == 0 }
      thread.exit

      pop_stat(id)

      output.puts "Failures: " if redis.llen("failure_#{id}") > 0

      each_object("failure_#{id}") do |failure|
        dump_failure(failure)
        dump_backtrace(failure[:exception])
      end
      exit(success ? 0 : 1)
    ensure
      if redis
        redis.del("to_run_#{id}")
        redis.del("stat_#{id}")
        redis.del("failure_#{id}")
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
        output.puts obj.inspect
      end
    end

    def each_object(key)
      while data = redis.lpop(key)
        yield(Marshal.load(data))
      end
    end

    def dump_failure(failure)
      exception = failure[:exception]
      exception_class_name = exception.class.to_s
      output.puts
      output.puts "* #{failure[:description]}"
      output.puts "\tFailure/Error: #{failure[:position]}"
      output.puts "\t#{exception_class_name}:" unless exception_class_name =~ /RSpec/
      exception.message.to_s.split("\n").each { |line| output.puts "\t  #{line}" } if exception.message
    end

    def dump_backtrace(exception)
      lines = RSpec::Core::BacktraceFormatter.format_backtrace(exception.backtrace,
                                                               { full_backtrace: @options.options[:full_backtrace] })
      lines.each do |line|
        output.puts "\t#{line}"
      end
    end

    def register_files(redis, id)
      sort_by_size(@configuration.files_to_run).uniq.each do |f|
        redis.rpush "to_run_#{id}", f
      end
    end

    # large to small
    def sort_by_size(files)
      files.sort_by { |file| -File.stat(file).size }
    end
  end
end
