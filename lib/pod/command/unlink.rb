module Pod
  class Command
    class Unlink < Command
      self.summary = 'Remove pod links'
      self.description = <<-DESC
        Using 'pod unlink <POD_NAME>' in a project folder will remove a link to 
        registered pod. You can also use .podlinks file to denote pods to link.
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
