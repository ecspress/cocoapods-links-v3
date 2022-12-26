require 'pod/links'

module Pod
  class Command
    class Unlink < Command
      self.summary = 'Remove pod links'
      self.description = <<-DESC
        The unlink functionality allows developers to remove reference to their local pods
        when they are finished testing

        Using 'pod unlink' in a project folder will remove the global link.
        
        Using 'pod unlink <name>' will remove the link to the <name> developement pod
        and install the <name> pod configured in the Podfile

        This allows to easily remove developement pod references
      DESC

      self.arguments = [
        CLAide::Argument.new('POD_NAME', false)
      ]

      def self.options
        []
      end

      def initialize(argv)
        @pods = argv.arguments!
        super
      end

      #
      # if no pod is given from the command line then we will look for the .podlinks file
      #
      # if no pods names are available to unlink, show help
      # 
      def validate!
        super
        if @pods.empty?
          @pods = Pod::Command::Links.podsFromLinkFile
        end
        help! "specify pods to unlink by running `pod unlink podname` or use .podlinks file" unless !@pods.empty?
      end
      
      def run 
        Pod::Command::Links.unlink @pods
      end

    end
  end
end
