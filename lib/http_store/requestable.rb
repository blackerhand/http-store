module HttpStore
  module Requestable
    def build_request
      # callback
    end

    def request_valid?
      true
    end

    def json_request?
      data_type.to_s.casecmp('json').zero?
    end

    def file_request?
      @data_hash.to_json.size > GRAPE_API::HTTP_FILE_SIZE_LIMIT
    end

    def get?
      http_method.to_s.casecmp('get').zero?
    end

    def post?
      http_method.to_s.casecmp('post').zero?
    end

    def default_request
      @headers_hash                ||= { charset: 'UTF-8' } # accept: :json
      @query_params_hash           ||= {}
      @data_hash                   ||= {}
      @headers_hash[:content_type] = :json if json_request?

      self.headers      = @headers_hash.to_json
      self.data         = @data_hash.to_json unless file_request?
      self.query_params = @query_params_hash.to_json
    end
  end
end
