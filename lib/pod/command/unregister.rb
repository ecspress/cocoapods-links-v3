require 'pod/links'

module Pod
  class Command
    class Unregister < Command
      self.summary = 'Register pod links for local pod development'
      self.description = <<-DESC
        Using 'pod register' in a project folder will create a global link.
        Then, in some other pod, 'pod link <name>' will create a link to 
        the registered pod as a Development pod.
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
