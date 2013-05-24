require 'rspec/core/formatters/base_formatter'

module Qspec
  module Formatters
    module RedisFormatterFactory
      def self.build(id, file)
        Class.new(RSpec::Core::Formatters::BaseFormatter) do
          @@id = id
          @@file = file
          include RedisFormatterFactory
        end
      end

      def initialize(output)
        @ipc = IPC.available_instance
        super
      end

      def dump_failures
        failed_examples.each do |example|
          ex = example.execution_result[:exception]
          data = {
            description: example.full_description,
            exception: format_exception(example, ex),
            backtrace: format_backtrace(ex.backtrace, example)
          }
          @ipc.rpush("failure_#{@@id}", Marshal.dump(data))
        end
      end

      def dump_summary(duration, example_count, failure_count, pending_count)
        data = [@@file, duration, example_count, failure_count, pending_count]
        @ipc.rpush("stat_#{@@id}", Marshal.dump(data))
      end

      def format_exception(example, ex)
        exception_class_name = ex.class.to_s
        output = StringIO.new
        output.puts "* #{example.full_description}"
        output.puts "\tFailure/Error: #{read_failed_line(ex, example)}"
        output.puts "\t#{exception_class_name}:" unless exception_class_name =~ /RSpec/
        ex.message.to_s.split("\n").each { |line| output.puts "\t  #{line}" } if ex.message
        output.string
      end
    end
  end
end
