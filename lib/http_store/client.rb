module HttpStore
  class Client
    META_KEYS = %w[http_method url data_type headers query_params data other_params request_valid
                   status_code response response_headers response_valid response_data
                   request_digest client_type requestable requestable_id requestable_type response_obj]

    attr_accessor :meta

    include HttpStore::Helpers::Requestable
    include HttpStore::Helpers::Responseable
    include HttpStore::Helpers::Storable

    def self.execute(requestable, other_params = {})
      new(requestable:      requestable,
          requestable_id:   requestable.try(:id),
          requestable_type: requestable.try(:class).try(:to_s),
          client_type:      to_s,
          other_params:     other_params)
    end

    def initialize(args)
      @meta                = Hashie::Mash.new(args)
      @meta.request_digest = gen_request_digest(@meta.to_json)

      build_request

      execute if request_valid # send request
      raise HttpStore::RequestError, 'response_obj is nil' if response_obj.nil?

      build_response
    ensure
      store_request
    end

    def gen_request_digest(str)
      Digest::SHA1.hexdigest(str)
    end

    META_KEYS.each do |meta_key|
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
      @meta.merge! Hashie::Mash.new(hash).slice(*META_KEYS)
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

