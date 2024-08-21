module HttpStore
  module Helpers
    module Responseable
      # check response message is right, if is right
      def response_valid?
        status_code >= 200 && status_code < 400
      end

      def need_retry?
        !response_valid?
      end

      def json_response?
        response_headers_hash['content_type'].to_s =~ /json/
      end

      def build_response
        response       = json_safe_parse(response_obj.body)
        response       = { original: response } unless response.is_a?(Hash)
        @meta.response = response

        @meta.status_code      = response_obj.code
        @meta.response_headers = response_obj.headers
        @meta.response_valid   = response_valid?
        @meta.response_code    = build_response_code
        @meta.response_data    = build_response_data
        @meta.cache_response   = cache_response?
        raise HttpStore::RequestError, '三方请求异常, 请与管理员联系' if response_data.nil?

        Rails.logger.info "#{uri}: response: #{response}"
        Rails.logger.info "#{uri}: response_data: #{response_data}"
      end

      def build_response_data
        response_valid ? 'success' : 'error'
      end

      def build_response_code
        response_valid? ? 200 : 422
      end

      def cache_response?
        response_valid?
      end

      # callback
      def after_response; end
    end
  end
end
