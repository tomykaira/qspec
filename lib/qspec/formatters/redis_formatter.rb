require 'redis'
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
        @redis = Redis.new
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
          @redis.rpush("failure_#{@@id}", Marshal.dump(data))
        end
      end

      def dump_summary(duration, example_count, failure_count, pending_count)
        data = [@@file, duration, example_count, failure_count, pending_count]
        @redis.rpush("stat_#{@@id}", Marshal.dump(data))
      end
    end
  end
end
