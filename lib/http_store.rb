require 'active_record'
require 'rails/engine'
require 'active_support/core_ext/module'

require 'hashie'
require 'rest-client'

module HttpStore
  class RequestError < StandardError; end


  extend ActiveSupport::Autoload

  autoload :Engine
  autoload :VERSION

  autoload :Requestable
  autoload :Responseable
  autoload :HttpLog
  autoload :Client
end
