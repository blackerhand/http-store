require "http_store/version"
require 'byebug'
require 'active_record'
require 'rails/engine'
require 'http_store/engine'
require 'active_support/core_ext/module'

module HttpStore
  class Error < StandardError; end
  extend ActiveSupport::Autoload

  autoload :Requestable
  autoload :Responseable
  autoload :RestRequest
end
