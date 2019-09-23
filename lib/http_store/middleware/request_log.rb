module HttpStore
  module Middleware
    class RequestLog
      include HttpStore::Helpers::Storable

      STRING_LIMIT_SIZE = 30_000

      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)
        [status, headers, body]
      ensure
        build_meta(env, status, headers, body)
        store_request
      end

      def build_meta(env, status, headers, body)
        request = ActionDispatch::Request.new(env)

        @meta = format_req(request)
        @meta.merge!(format_rsp(status, headers, body))
      end

      def format_req(request)
        {
          data:         request.params,
          headers:      request.headers.select { |k, _v| k.start_with? 'HTTP_' }.to_h,
          query_params: request.query_parameters
        }
      end

      def format_rsp(status, headers, body)
        {
          status_code:      status,
          response_headers: headers,
          response:         body.try(:body) || body
        }
      end
    end
  end
end
