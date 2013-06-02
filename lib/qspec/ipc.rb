module Qspec
  # abstract
  class IPC
    def self.from_config(config)
      name = config['ipc']
      @@default =
        case name
        when 'redis'
          require 'qspec/ipc/redis'
          IPC::Redis.new(config['redis'])
        when 'file', nil
          require 'qspec/ipc/file'
          IPC::File.new(config['file'])
        else
          raise "Unknown IPC method #{name}"
        end
    end

    def self.default
      @@default || (raise 'Default IPC module not set')
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
