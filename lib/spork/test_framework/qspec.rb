require 'spork'
class Spork::TestFramework::Qspec < Spork::TestFramework
  DEFAULT_PORT = 9240
  HELPER_FILE = File.join(Dir.pwd, "spec/spec_helper.rb")

  def run_tests(argv, stderr, stdout)
    ::Qspec::CommandLine.new(argv).run(stderr, stdout)
  end
end
