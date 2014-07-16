module Qspec
  class Helper
    def initialize(argv)
      @argv = argv
    end

    def serve
      case @argv.last
      when 'init'
        puts "Creating template"
        Config.create_template
      end
    end
  end
end
