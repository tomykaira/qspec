require 'rspec/core'
require 'qspec/version'
require 'qspec/ipc'
require 'qspec/manager'
require 'qspec/spork_helper'
require 'qspec/command_line'
require 'qspec/formatters/redis_formatter'
require 'qspec/config'
require 'qspec/helper'

module Qspec
  DIRECTORY = File.expand_path(Config.new['tmp_directory'] || 'tmp/qspec')

  FileUtils.mkdir_p(DIRECTORY) unless FileTest.exists?(DIRECTORY)

  def self.path(filename)
    File.join(DIRECTORY, filename)
  end
end
