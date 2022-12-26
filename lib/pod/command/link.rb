require 'pod/links'

module Pod
  class Command
    class Link < Command
      self.summary = 'Create pod links for local pod development'
      self.description = <<-DESC
        The link functionality allows developers to easily test their pods.
        Linking is a two-step process:

        Using 'pod register' in a project folder will create a global link.
        
        Then, in some other pod, 'pod link <POD_NAME>' will create a link to 
        the local pod as a Development pod. You can also use .podlinks file to denote pods to link.

        This allows to easily test a pod because changes will be reflected immediately.
        When the link is no longer necessary, simply remove it with 'pod unlink <name>'.
      DESC

      self.arguments = [
        CLAide::Argument.new('POD_NAME', false)
      ]

      def self.options
        []
      end

      def initialize(argv)
        @pods = argv.arguments!.uniq
        super
      end

      #
      # if no pod is given from the command line then we will look for the .podlinks file
      #
      # if no pods names are available to link, show help
      # 
      def validate!
        super
        if @pods.empty?
          @pods = Pod::Command::Links.podsFromLinkFile
        end
        help! "specify pods to link by running `pod link [POD_NAME]` or use .podlinks file" unless !@pods.empty?
      end
      
      def run 
        Pod::Command::Links.link @pods
      end
    end
  end
end
