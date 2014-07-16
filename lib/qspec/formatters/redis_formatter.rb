require 'rspec/core/formatters/base_formatter'

module Qspec
  module Formatters
    module RedisFormatterFactory
      def self.build(id, file)
        Class.new(RSpec::Core::Formatters::BaseFormatter) do
          RSpec::Core::Formatters.register self, :dump_summary, :dump_failures
          @@id = id
          @@file = file
          include RedisFormatterFactory
        end
      end

      def initialize(output)
        @ipc = IPC.default
        super
      end

      def dump_failures(notification)
        notification.failure_notifications.each do |failure|
          data = {
            description: failure.description,
            exception: failure.message_lines.join("\n"),
            backtrace: failure.formatted_backtrace
          }
          @ipc.rpush("failure_#{@@id}", Marshal.dump(data))
        end
      end

      def dump_summary(summary)
        data = [@@file, summary.duration, summary.examples.size, summary.failed_examples.count, summary.pending_examples.count]
        @ipc.rpush("stat_#{@@id}", Marshal.dump(data))
      end
    end
  end
end
