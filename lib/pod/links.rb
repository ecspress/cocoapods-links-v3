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

      #
      # Register pods for local development in the current working directory. This working
      # directory must have at least one .podspec
      # 
      def self.register
        specs = self.podspecs
        currentDir = Dir.pwd
        help! 'A .podspec must exist in the directory `pod register` is ran' if specs.empty?
        specs.each do |spec|
          self.print "Registering '#{spec.name}' > #{currentDir}"
          self.write_db(REGISTERED_DB, self.registerd_db, {
            spec.name => {
              "path" => currentDir
            }
          })
        end
      end

      #
      # Unregister pods
      # 
      def self.unregister
        specs = self.podspecs
        currentDir = Dir.pwd
        help! 'A .podspec must exist in the directory `pod unregister` is ran' if specs.empty?
        specs.each do |spec|
          self.print "Unregistering '#{spec.name}' > #{currentDir}"
          db = self.registerd_db
          db.delete(spec.name)
          self.write_db(REGISTERED_DB, db)
        end 
      end

      #
      # Retrieve pod names from .podlink file
      # 
      # @returns the pods to link
      # 
      def self.podsFromLinkFile
        linkFiles = Dir["#{Dir.pwd}/.podlinks"]
        if linkFiles.empty?
          return []
        end
        pods = File.readlines(linkFiles.fetch(0), chomp: true).uniq
        return pods
      end

      #
      # Creates a link for the given pods into the current project. The pods must be registered
      # using `pod register`
      # 
      # @param pods the names of the pods to link into the current project 
      # 
      def self.link(pods)
        currentDir = Dir.pwd
        db = self.linked_db
        linked_pods = self.linked_pods

        pods.each do |pod|
          # only allow registered links to be used
          registered_link = self.get_registered_link pod
          if registered_link.nil?
            Command::help! "Pod '#{pod}'' is not registered. Did you run `pod link` from the #{pod} directory?"
          end

          # add the linked pod
          linked_pods = linked_pods << pod
          self.print "Adding link to '#{pod}' > #{registered_link['path']}"
        end


        self.write_db(LINKED_DB, db, {
          currentDir => {
            'pods' => linked_pods.uniq
          }
        })

        # install pod from link
        Pod::Command::Install.run(["--project-directory=#{currentDir}"])
      end

      #
      # Will unlink the give pods from the current pod project
      # 
      # @param pods the names of the pods to unlink
      # 
      def self.unlink(pods)
        currentDir = Dir.pwd

        db = self.linked_db
        linked_pods = self.linked_pods
        if !linked_pods.empty?
          pods.each do |pod|
            linked_pods.delete(pod)
            self.print "Removing link to '#{pod}'"
          end

          #
          # Update databased based on link state
          # if links exist, update list of links
          # if links do not exist, remove entry
          # 
          if linked_pods.empty?
            db.delete(currentDir)
            self.write_db(LINKED_DB, db)
          else
            self.write_db(LINKED_DB, db, {
              currentDir => {
                'pods' => linked_pods
              }
            })
          end

          # install pod from repo
          Pod::Command::Install.run(["--project-directory=#{currentDir}"])
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
      # List the registered pods. 
      # 
      def self.list_registered(local = false)
        currentDir = Dir.pwd
        self.print "Registered pods:"
        self.registerd_db.each do |pod, link|
          path = link['path']
          if !local || (currentDir == path)
            self.print "* #{pod} > #{path}"
          end
        end
      end

      #
      # List the linked pods.
      # 
      def self.list_linked(local = false)
        currentDir = Dir.pwd
        self.print "Linked pods:"
        self.linked_db.each do |path, pods|
          podnames = pods['pods']
          if !local || (currentDir == path)
            podnames.each { |name| self.print "* #{name}" }
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
        db = self.registerd_db
        if db.has_key?(name)
          return db[name]
        end
        return nil
      end

      #
      # Retrieve the names of the linked pods for the current project (e.g. the current directory)
      # 
      # @returns a list of pods that are linked for the current project
      # 
      def self.linked_pods
        currentDir = Dir.pwd
        db = self.linked_db
        if db.has_key?(currentDir)
          return db[currentDir]['pods']
        end
        return []
      end

      # 
      # Read the podspecs in the current working directory
      # 
      # @returns the podspecs
      # 
      def self.podspecs
        specs = Dir["#{Dir.pwd}/*.podspec"]
        return specs.map { |spec| Specification.from_file(spec) } 
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
