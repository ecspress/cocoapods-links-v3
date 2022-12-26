module Pod
  class Command
    class List < Command
      self.summary = 'Lists registered and linked pods'
      self.description = <<-DESC
        List the registered and linked pods
      DESC

      self.arguments = []

      def self.options
        [
          ['--registered', 'List registered pods'],
          ['--linked', 'List linked pods'],
          ['--local', 'List local pods only'],
        ]
      end

      def initialize(argv)
        @showRegistered = argv.flag?('registered')
        @showLinked = argv.flag?('linked')
        @local = argv.flag?('local')
        super
      end

      def validate!
        super
        help! "specify option to list by using --registered or --linked" unless (@showRegistered || @showLinked)
      end

      def run
        if @showRegistered
          Pod::Command::Links.list_registered @local
        else
          Pod::Command::Links.list_linked @local
        end
      end
    end
  end
end
