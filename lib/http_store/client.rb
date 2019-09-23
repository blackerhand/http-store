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

      # exist request or not force, return
      return if !force && storeable_record.present?

      execute # send request
      raise HttpStore::RequestError, 'response_obj is nil' if response_obj.nil?

      build_response
    ensure
      store_request
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
    end

    def http_get_execute
      RestClient.get(uri, headers)
    rescue RestClient::ExceptionWithResponse => e
      # :nocov:
      e.response
      # :nocov:
    end

    def http_post_execute
      real_data = json_request? ? data.to_json : data.to_hash
      RestClient.post(uri, real_data, headers.symbolize_keys)
    rescue RestClient::ExceptionWithResponse => e
      # :nocov:
      e.response
      # :nocov:
    end

    def json_safe_parse(str)
      JSON.parse(str) rescue str
    end
  end
end

