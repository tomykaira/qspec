require 'spork/test_framework/qspec'

module Qspec
  module SporkHelper
    PORT = ::Spork::TestFramework::Qspec::DEFAULT_PORT

    def start_spork_workers
      @qspec_opts[:count].times do |i|
        spawn({ "TEST_ENV_NUMBER" => i == 0 ? '' : (i + 1).to_s },
              "spork qspec --port #{PORT+i}")
      end
      Signal.trap(:INT){
        output.puts "Stop spork processes"
        exit(0)
      }
      Process.waitall.all? { |pid, status| status.exitstatus == 0 } ? 0 : 1
    end
  end
end
