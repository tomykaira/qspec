require 'drb/drb'
require 'spork/test_framework/qspec'

module Qspec
  module SporkHelper
    PORT = ::Spork::TestFramework::Qspec::DEFAULT_PORT

    def start_spork_workers
      Signal.trap(:INT){
        output.puts "Stop spork processes"
        remove_port_file
        exit(0)
      }

      ports = []
      @options.options[:count].times do |i|
        spawn({ "TEST_ENV_NUMBER" => i == 0 ? '' : (i + 1).to_s },
              "spork qspec --port #{PORT+i}")
        ports << PORT+i
      end
      create_port_file(ports)
      Process.waitall.all? { |pid, status| status.exitstatus == 0 } ? 0 : 1
    end

    def connect_spork(port, id, err, out)
      begin
        DRb.start_service("druby://localhost:0")
      rescue SocketError, Errno::EADDRNOTAVAIL
        DRb.start_service("druby://:0")
      end
      spec_server = DRbObject.new_with_uri("druby://127.0.0.1:#{port||PORT}")
      spec_server.run(@options.drb_argv + ['--id', id.to_s], err, out)
    end

    def create_port_file(ports)
      File.open('tmp/qspec_spork', 'w') do |f|
        f.puts ports.join("\n")
      end
    end

    def runnning_ports
      @runnning_ports ||= begin
        ports = File.readlines('tmp/qspec_spork').map { |line| line.strip.to_i }
        ports.empty? ? nil : ports
      rescue Errno::ENOENT
        nil
      end
    end

    def remove_port_file
      File.unlink('tmp/qspec_spork')
    end
  end
end
