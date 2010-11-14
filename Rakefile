require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sarlacc"
    gem.summary = %Q{A fearsome alien beast that consumes data feeds}
    gem.description = %Q{A library that monitors data feeds for new entries}
    gem.email = "bcm@maz.org"
    gem.homepage = "http://github.com/bcm/sarlacc"
    gem.authors = ["Brian Moseley"]
    gem.add_dependency "feedzirra", ">= 0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

Dir[File.join(File.dirname(__FILE__), 'tasks/*.rake')].each { |rake| load rake }
