require 'active_record'
require 'rails/engine'
require 'active_support/core_ext/module'
require 'hashie'
require 'rest-client'
require 'http_store/engine'

module HttpStore
  extend ActiveSupport::Autoload

  module Helpers
    extend ActiveSupport::Autoload

    autoload :Requestable
    autoload :Responseable
    autoload :Storable
  end

  autoload :Engine
  autoload :VERSION
  autoload :HttpLog
  autoload :Client

  class RequestError < StandardError; end
end
