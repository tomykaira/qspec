module Qspec
  class Helper
    include SporkHelper

    def initialize(argv)
      @argv   = argv
    end

    def serve
      case @argv.last
      when 'init'
        puts "Creating template"
        Config.create_template
      when 'spork'
        @config = Config.new
        puts "Start #{@config['workers']} sporks"
        start_spork_workers(@config['workers'])
      end
    end
  end
end
