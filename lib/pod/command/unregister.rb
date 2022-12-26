module Pod
  class Command
    class Unregister < Command
      self.summary = 'Unregister development pod'
      self.description = <<-DESC
        Using 'pod unregister' in a project folder will remove global links to development pods.
      DESC
      
      self.arguments = []

      def self.options
        []
      end

      def initialize(argv)
        super
      end

      #
      # if no pod is given from the command line then we will create a link for the current pod
      # so other pods can link it as a development dependency
      #
      # if a pod name is given from the command line then we will link that pod into the current
      # pod as a development dependency
      #
      def run
        Pod::Command::Links.unregister
      end
    end
  end
end
