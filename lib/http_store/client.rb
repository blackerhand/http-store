module HttpStore
  class Client
    attr_accessor :meta

    include HttpStore::Helpers::Requestable
    include HttpStore::Helpers::Responseable
    include HttpStore::Helpers::Storable

    def self.execute(requestable, other_params = {})
      new(requestable: requestable, other_params: other_params)
    end

    def initialize(args)
      @meta = Hashie::Mash.new(args)
      build_request

      return unless request_valid?
      load_storeable_record and return if use_cache?

      execute # send request
      retry! while need_retry? && retry_times.to_i > 0

      after_response
    end

    def retry!
      @meta.retry_times = retry_times.to_i - 1
      @meta.force       = true

      execute
    end

    HttpStore::ALL_KEYS.each do |meta_key|
      define_method meta_key do
        @meta.send(meta_key)
      end
    end

    private

    def build_request
      add_meta(set_request)
      format_request
    end

    def add_meta(hash)
      @meta.merge! Hashie::Mash.new(hash).slice(*HttpStore::REQUEST_KEYS)
    end

    def execute
      @meta.response_obj = get? ? http_get_execute : http_post_execute
      raise HttpStore::RequestError, 'response_obj is nil' if response_obj.nil?

      build_response
    ensure
      store_request
    end

    def verify_ssl
      !!other_params[:verify_ssl]
    end

    def http_get_execute
      RestClient::Request.execute(method: :get, url: uri, headers: headers.symbolize_keys, verify_ssl: verify_ssl)
    rescue RestClient::ExceptionWithResponse => e
      # :nocov:
      e.response
      # :nocov:
    end

    def http_post_execute
      real_data = json_request? ? data.to_json : data.to_hash
      # RestClient.post(uri, real_data, headers.symbolize_keys)
      RestClient::Request.execute(method: :post, url: uri, payload: real_data, headers: headers.symbolize_keys, verify_ssl: verify_ssl)
    rescue RestClient::ExceptionWithResponse => e
      # :nocov:
      e.response
      # :nocov:
    end
  end
end

