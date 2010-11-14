require 'active_support/core_ext/module/attribute_accessors'

require 'sarlacc/fetcher'
require 'sarlacc/source'

module Sarlacc
  mattr_accessor :logger, :instance_writer => false
end
