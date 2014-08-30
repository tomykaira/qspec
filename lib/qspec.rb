require 'rspec/core'

require 'qspec/version'
require 'qspec/ipc'
require 'qspec/command_line'
require 'qspec/formatters/redis_formatter'
require 'qspec/config'
require 'qspec/helper'

module Qspec
  class << self
    def path(filename)
      File.join(tmp_directory_path, filename)
    end

    def tmp_directory_path
      @tmp_directory_path ||= File.expand_path(Config.new['tmp_directory'] || 'tmp/qspec')
    end

    def create_tmp_directory_if_not_exist
      FileUtils.mkdir_p(tmp_directory_path) unless FileTest.exists?(tmp_directory_path)
    end
  end
end
