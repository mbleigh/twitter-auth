require 'rake'
require 'spec/rake/spectask'

desc 'Default: run specs.'
task :default => :spec

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "twitter-auth"
    s.summary = "TwitterAuth is a Rails plugin gem that provides Single Sign-On capabilities for Rails applications via Twitter."
    s.email = "michael@intridea.com"
    s.homepage = "http://github.com/mbleigh/twitter-auth"
    s.description = "TwitterAuth is a Rails plugin gem that provides Single Sign-On capabilities for Rails applications via Twitter. Both OAuth and HTTP Basic are supported."
s.files =  FileList["[A-Z]*", "{bin,generators,lib,spec,config,app,rails}/**/*"] - FileList["**/*.log"]
    
    s.authors = ["Michael Bleigh"]
    s.add_dependency('oauth', '>= 0.3.1')
    s.add_dependency('ezcrypto', '>= 0.7.2')
    s.rubyforge_project = 'twitter-auth'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

