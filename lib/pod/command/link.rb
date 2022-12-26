module Pod
  class Command
    class Link < Command
      self.summary = 'Create pod links for local pod development'
      self.description = <<-DESC
        Using 'pod link <POD_NAME>' in a project folder will create a link to 
        registered pod. You can also use .podlinks file to denote pods to link.
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
