require 'pod/links'

module Pod
  class Command
    class Register < Command
      self.summary = 'Create pod links for local pod development'
      self.description = <<-DESC
        The link functionality allows developers to easily test their pods.
        Linking is a two-step process:

        Using 'pod register' in a project folder will create a global link.
        Then, in some other pod, 'pod link <name>' will create a link to 
        the local pod as a Development pod.

        This allows to easily test a pod because changes will be reflected immediately.
        When the link is no longer necessary, simply remove it with 'pod unlink <name>'.
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
