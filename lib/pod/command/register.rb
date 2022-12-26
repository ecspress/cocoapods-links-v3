module Pod
  class Command
    class Register < Command
      self.summary = 'Register development pod'
      self.description = <<-DESC
        Using 'pod register' in a project folder will add global links to development pods.
      DESC
      
      self.arguments = []

      def self.options
        []
      end

      def initialize(argv)
        super
      end

      #
      # we will create links for all the current pods
      # so other pods can link as development dependencies
      #
      def run
        Pod::Command::Links.register
      end
    end
  end
end
