require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "gloo"
    gem.summary = %Q{Different ORMs living in the same app? Gloo them together!}
    gem.description = %Q{Different ORMs living in the same app? Gloo them together!}
    gem.email = "michael@intridea.com"
    gem.homepage = "http://github.com/intridea/gloo"
    gem.authors = ["Michael Bleigh"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_dependency 'activerecord', '>= 3.0.0.beta'
    gem.add_dependency 'activesupport', '>= 3.0.0.beta'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rspec/core/rake_task'
Rspec::Core::RakeTask.new(:spec) do |spec|
  #spec.libs << 'lib' << 'spec'
  #spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.pattern = 'spec/**/*_spec.rb'
end

Rspec::Core::RakeTask.new(:rcov) do |spec|
  #spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "gloo #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
