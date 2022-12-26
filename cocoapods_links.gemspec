# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods_links.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-links-v3'
  spec.version       = CocoapodsLinks::VERSION
  spec.authors       = ['ecspress']
  spec.email         = ['ecspress@hotmail.com']
  spec.summary       = 'A CocoaPods plugin for linking and unlinking local pods for local development'
  spec.description   = <<-DESC
                        Using 'pod register' in a project folder will create a global link.
        
                        Then, in some other pod, 'pod link <POD_NAME>' will create a link to 
                        the local pod as a Development pod. You can also use .podlinks file to denote pods to link.

                        This allows to easily test a pod because changes will be reflected immediately.
                        When the link is no longer necessary, simply remove it with 'pod unlink <name>'.

                        This plugin adds the following commands to the CocoaPods command line:
                         
                        * pod register
                        * pod unregister
                        * pod link <name>
                        * pod unlink <name>
                        * pod list <flags>

                      DESC
  spec.homepage      = 'https://github.com/ecspress/cocoapods-links-v3'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ['lib']

  spec.add_dependency 'cocoapods', '~> 1.11'
  spec.add_dependency 'json', '~> 2.6'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
end
