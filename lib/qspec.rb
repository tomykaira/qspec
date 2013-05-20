require 'qspec/version'
require 'qspec/ipc'
require 'qspec/manager'
require 'qspec/spork_helper'
require 'qspec/configuration_options'
require 'qspec/option_parser'
require 'qspec/command_line'
require 'qspec/formatters/redis_formatter'

module Qspec
  DIRECTORY = File.expand_path('tmp/qspec')

  FileUtils.mkdir_p(DIRECTORY) unless FileTest.exists?(DIRECTORY)

  def self.path(filename)
    File.join(DIRECTORY, filename)
  end
end
