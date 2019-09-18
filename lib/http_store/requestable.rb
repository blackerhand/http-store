module HttpStore
  module Requestable
    # will return one hash to set the request meta
    def set_request
      {}
    end

    # you need rewrite this checker, when return false the request don't send
    def request_valid?
      true
    end

    def json_request?
      data_type.to_s.casecmp('json').zero?
    end

    def uri
      "#{url}?#{query_params.to_query}"
    end

    def get?
      http_method.to_s.casecmp('get').zero?
    end

    def post?
      http_method.to_s.casecmp('post').zero?
    end

    def format_request
      @meta.http_method = get? ? 'GET' : 'POST' # only support get/post

      @meta.headers                ||= { charset: 'UTF-8' }
      @meta.headers[:content_type] = :json if json_request?

      @meta.query_params ||= {}
      @meta.data         ||= {}

      @meta.request_valid = request_valid?
    end
  end
end
