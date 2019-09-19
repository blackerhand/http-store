require 'active_record'
require 'rails/engine'
require 'active_support/core_ext/module'

require 'hashie'
require 'rest-client'

module HttpStore
  extend ActiveSupport::Autoload

  autoload :Engine
  autoload :VERSION

  autoload :Requestable
  autoload :Responseable
  autoload :Storable
  autoload :HttpLog
  autoload :Client

  class RequestError < StandardError; end
end
