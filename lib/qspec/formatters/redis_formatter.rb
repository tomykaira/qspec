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
            position: read_failed_line(ex, example),
            exception: ex
          }
          @ipc.rpush("failure_#{@@id}", Marshal.dump(data))
        end
      end

      def dump_summary(duration, example_count, failure_count, pending_count)
        data = [@@file, duration, example_count, failure_count, pending_count]
        @ipc.rpush("stat_#{@@id}", Marshal.dump(data))
      end
    end
  end
end
