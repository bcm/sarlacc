DAEMON_ENV = 'test' unless defined?( DAEMON_ENV )

require 'rspec'

require File.dirname(__FILE__) + '/../config/environment'
DaemonKit::Application.running!

RSpec.configure do |c|
end
