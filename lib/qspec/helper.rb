module Qspec
  class Helper
    include SporkHelper

    def initialize(argv)
      @argv   = argv
      @config = Config.new
    end

    def serve
      case @argv.last
      when 'init'
        puts "Creating template"
        Config.new.create_template
      when 'spork'
        puts "Start #{@config['workers']} sporks"
        start_spork_workers(@config['workers'])
      end
    end
  end
end
