require 'redis'
module Qspec
  class IPC
    class Redis < IPC
      def initialize(config)
        config ||= {}
        @redis = ::Redis.new(config)
        @namespace = config['namespace'] || 'qspec'
      end

      [:del, :lpop, :rpush, :llen].each do |method|
        define_method(method) do |*args|
          key = args.shift
          @redis.send(method, "#{@namespace}:#{key}", *args)
        end
      end
    end
  end
end
