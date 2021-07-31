# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods_links.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-links-v2'
  spec.version       = CocoapodsLinks::VERSION
  spec.authors       = ['Hai Feng Kao']
  spec.email         = ['haifeng@cocoaspice.in']
  spec.summary       = 'A CocoaPods plugin for linking and unlinking local pods for local development'
  spec.description   = <<-DESC
                         This CocoaPods plugin linking functionality allows to easily test their pods.

                         This plugin adds the following commands to the CocoaPods command line:

                          * pod link <name>
                          * pod unlink <name>
                          * pod list links

                       DESC
  spec.homepage      = 'https://github.com/haifengkao/cocoapods-links-v2'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ['lib']

  spec.add_dependency 'cocoapods', '~> 1.0'
  spec.add_dependency 'json', '~> 2'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.4'
end
