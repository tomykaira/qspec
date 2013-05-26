require 'redis'
module Qspec
  class IPC
    class Redis < IPC
      def initialize
        @redis = ::Redis.new
      end

      [:del, :lpop, :rpush, :llen].each do |method|
        define_method(method) do |*args|
          @redis.send(method, *args)
        end
      end
    end
  end
end
