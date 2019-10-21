require 'active_record'
require 'rails/engine'
require 'active_support/core_ext/module'
require 'hashie'
require 'rest-client'
require 'http_store/engine'

module HttpStore
  extend ActiveSupport::Autoload

  REQUEST_KEYS  = %w[http_method url data_type headers query_params data other_params force request_valid]
  RESPONSE_KEYS = %w[status_code response response_headers response_data response_valid response_code cache_response]
  META_KEYS     = %w[request_digest client_type parent_id requestable_id requestable_type]
  TMP_KEYS      = %w[requestable response_obj]

  DIGEST_KEYS = %w[http_method url data_type data other_params requestable_id requestable_type]
  ALL_KEYS    = REQUEST_KEYS + RESPONSE_KEYS + META_KEYS + TMP_KEYS
  STORE_KEYS  = REQUEST_KEYS + RESPONSE_KEYS + META_KEYS

  class RequestError < StandardError; end

  module Helpers
    extend ActiveSupport::Autoload

    autoload :Requestable
    autoload :Responseable
    autoload :Storable
  end

  module Middleware
    extend ActiveSupport::Autoload

    autoload :RequestLog
  end

  autoload :Engine
  autoload :VERSION
  autoload :HttpLog
  autoload :Client
  autoload :Configuration

  class << self
    def config
      @config ||= Configuration.new
    end

    def configure(&block)
      yield(config)
    end
  end
end
