module Qspec
  # abstract
  class IPC
    def self.available_instance
      if self.constants.include?(:Redis)
        IPC::Redis.new
      else
        IPC::File.new
      end
    end

    def del(key)
    end

    def lpop(key)
    end

    def rpush(key, value)
    end

    def llen(key)
    end
  end
end

require 'qspec/ipc/redis'
require 'qspec/ipc/file'
