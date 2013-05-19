require 'fileutils'

module Qspec
  class IPC
    class File < IPC
      DIRECTORY = 'tmp/qspec'

      def initialize
        FileUtils.mkdir_p(DIRECTORY) unless FileTest.exists?(DIRECTORY)
      end

      def del(key)
        ::File.unlink(file_name(key)) rescue nil
      end

      def lpop(key)
        open(key, :rw) do |f|
          list = safe_load(f)
          f.truncate(0)
          f.rewind
          data = list.shift
          f.write(Marshal.dump(list))
          data
        end
      end

      def rpush(key, value)
        open(key, :rw) do |f|
          list = safe_load(f)
          f.truncate(0)
          f.rewind
          list.push(value)
          f.write(Marshal.dump(list))
        end
      end

      def llen(key)
        open(key, :r) do |f|
          safe_load(f).length
        end
      end

      private
      def open(key, type)
        mode, lock = case type
                     when :rw then [::File::RDWR|::File::CREAT|::File::BINARY, ::File::LOCK_EX]
                     when :r  then [::File::RDONLY|::File::CREAT|::File::BINARY, ::File::LOCK_SH]
                     end
        ::File.open(file_name(key), mode) do |f|
          f.flock(lock)
          f.set_encoding('ASCII-8BIT')
          yield(f)
        end
      end

      def file_name(key)
        ::File.join(DIRECTORY, key)
      end

      def safe_load(f)
        data = f.read
        data.strip == '' ? [] : Marshal.load(data)
      end
    end
  end
end
