require 'json'
require 'fileutils'

module Pod
  class Command

    #
    # Links utility that provides functionality around managing CocoaPod links
    # 
    module Links

      #
      # Defines the path where the links database is stored (e.g. from pod link)
      # 
      REGISTERED_DB = File.expand_path('~/.cocoapods/plugins/link/registered.json')

      #
      # Defines the path where per pod links are stored (e.g. from pod link <foo> command)
      # 
      LINKED_DB = File.expand_path('~/.cocoapods/plugins/link/linked.json')

      # return the path which has '*.podspec'
      def self.registerProjectPath
        spec = Dir["#{Dir.pwd}/*.podspec"]
        unless spec.empty?
          return Dir.pwd
        end

        # check parent directory
        spec = Dir["#{Dir.pwd}/../*.podspec"]
        unless spec.empty?
          return File.expand_path("..", Dir.pwd)
        end

        help! 'A .podspec must exist in the directory `pod link` is ran'
      end

      # return the path which contains 'Podfile'
      def self.linkProjectPath
        spec = Dir["#{Dir.pwd}/Podfile"]
        unless spec.empty?
          return Dir.pwd
        end

        # check ./Example directory
        spec = Dir["#{Dir.pwd}/Example/Podfile"]
        unless spec.empty?
          return File.expand_path("Example", Dir.pwd)
        end

        help! 'Podfile must exist in the directory `pod link` is ran'
      end

      #
      # Register a pod for local development in the current working directory. This working
      # directory must have a .podspec defining the pod 
      # 
      def self.register
        self.print "Registering '#{self.podspec.name}' > #{self.registerProjectPath}"
        self.write_db(REGISTERED_DB, self.registerd_db, {
          self.podspec.name => {
            "path" => self.registerProjectPath
          }
        })
      end

      #
      # Unregister a pod
      # 
      def self.unregister
       self.print "Unregistering '#{self.podspec.name}' > #{self.registerProjectPath}"
        db = self.registerd_db
        db.delete(self.podspec.name)
        self.write_db(REGISTERED_DB, db)
      end

      #
      # Creates a link for the given pod into the current project. The pod must be registered
      # using `pod link`
      # 
      # @param pod the name of the pod to link into the current project 
      # 
      def self.link(pod)
        podfileFolder = self.linkProjectPath
        # only allow registered links to be used
        registered_link = self.get_registered_link pod
        if registered_link.nil?
          Command::help! "Pod '#{pod}'' is not registered. Did you run `pod link` from the #{pod} directory?"
        end

        # add the linked pod
        linked_pods = [pod]
        if self.linked_db.has_key?(podfileFolder)
          linked_pods = linked_pods.concat self.linked_db[podfileFolder]['pods']
        end

        self.print "Adding link to '#{pod}' > #{registered_link['path']}"
        self.write_db(LINKED_DB, self.linked_db, {
          podfileFolder => {
            'pods' => linked_pods.uniq
          }
        })

        # install pod from link
        Pod::Command::Install.run(["--project-directory=#{podfileFolder}"])
      end

      #
      # Will unlink the give pod from the current pod project
      # 
      # @param pod the name of the pod to unlink
      # 
      def self.unlink(pod)
        podfileFolder = self.linkProjectPath
        if self.linked_db.has_key?(podfileFolder)
          linked_pods = self.linked_db[podfileFolder]['pods']
          linked_pods.delete(pod)

          #
          # Update databased based on link state
          # if links exist, update list of links
          # if links do not exist, remove entry
          # 
          self.print "Removing link to '#{pod}'"
          if linked_pods.empty?
            db = self.linked_db
            db.delete(podfileFolder)
            self.write_db(LINKED_DB, db)
          else
            self.write_db(LINKED_DB, self.linked_db, {
              podfileFolder => {
                'pods' => linked_pods
              }
            })
          end

          # install pod from repo
          Pod::Command::Install.run(["--project-directory=#{podfileFolder}"])
        end
      end

      #
      # Entry point for the `pod` hook to check if the current pod project should use a linked pod
      # of installed from the pod requirements. In order for a link to be returned the following
      # must hold true:
      # 
      # 1. The pod must be registered (e.g. pod link)
      # 2. The current pod project must have linked the registered link (e.g. pod link <name>)
      # 
      # @param name the name of the pod to find a link for
      # 
      # @returns the registered link for the given name or nil
      #
      def self.get_link(name)
        if self.linked_pods.include?(name)
          return self.get_registered_link name
        end
        return nil
      end

      #
      # List the links. 
      # 
      # - If linked is true then list the linked pods in the current project
      # - Id linked is false then list the registered links
      # 
      # @param linked flag to determine which links to list
      # 
      def self.list(linked = false)
        if linked
          self.print "Linked pods:"
          self.linked_pods.each do |pod|
            self.print "* #{pod}"
          end
        else
          self.print "Registered pods:"
          self.registerd_db.each do |pod, link|
            self.print "* #{pod} > #{link['path']}"
          end
        end
      end

      #
      # Get list of pods that are linked for the current pod project
      # 
      # @return an array of installed links
      # 
      def self.installed_links
        installed = []
        self.linked_pods.each do |pod|
          unless self.get_registered_link(pod).nil?
            installed.append(pod)
          end
        end
        return installed
      end

      #
      # Prints a formatted message with the Pod Links prefix
      # 
      def self.print(message)
        UI.puts("Pod #{'Links'.cyan} #{message}")
      end
      
    private

      #
      # Retrieve the registered links database from disk
      # 
      # @returns the registered links database
      # 
      def self.registerd_db
        if File.exists?(REGISTERED_DB)
          return JSON.parse(File.read(REGISTERED_DB))
        end
        return {}
      end

      #
      # Retrieve the linked database from disk
      # 
      # @returns the linked database
      # 
      def self.linked_db
        if File.exists?(LINKED_DB)
          return JSON.parse(File.read(LINKED_DB))
        end
        return {}
      end

      #
      # Retrieve a link for the given name from the database. If the link does not exist in the
      # for the given name then this will return nil
      # 
      # @param name the name of the link to retrieve from the database
      # 
      # @return the link for the given name or nil
      # 
      def self.get_registered_link(name)
        if self.registerd_db.has_key?(name)
          return self.registerd_db[name]
        end
        return nil
      end

      #
      # Retrieve the names of the linked pods for the current project (e.g. the current directory)
      # 
      # @returns a list of pods that are linked for the current project
      # 
      def self.linked_pods
        podfileFolder = self.linkProjectPath
        if self.linked_db.has_key?(podfileFolder)
          return self.linked_db[podfileFolder]['pods']
        end
        return []
      end

      # 
      # Read the podspec in the current working directory
      # 
      # @returns the podspec
      # 
      def self.podspec
        spec = Dir["#{self.registerProjectPath}/*.podspec"]
        if spec.empty?
          help! 'A .podspec must exist in the directory `pod link` is ran'
        end
        return Specification.from_file(spec.fetch(0))
      end

      #
      # Will write the provided database to disk with the newly provided link content
      # 
      # @param filename the name of the file to write the links to
      # @param links the content to write to disk
      # 
      def self.write_db(db_path, db, entry = {})
        dirname = File.dirname(db_path)
        unless File.directory?(dirname)
          FileUtils.mkdir_p(dirname)
        end
        File.open(db_path,'w') do |f|
          f.write(JSON.pretty_generate(db.merge(entry)))
        end
      end
    end
  end
end
