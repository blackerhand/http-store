module HttpStore
  module Helpers
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

        @meta.requestable_id   = requestable.try(:id)
        @meta.requestable_type = requestable.try(:class).try(:to_s)
        @meta.client_type      = self.class.to_s
        @meta.request_digest   = gen_request_digest

        @meta.request_valid = request_valid?
      end

      def gen_request_digest
        request_str = storable_hash(@meta.slice(*HttpStore::DIGEST_KEYS)).to_json
        Digest::SHA1.hexdigest(request_str)
      end
    end
  end
end
