module HttpStore
  module Responseable
    # check response message is right, if is right
    def response_status_check
      status_code == 200
    end

    def response_error_handle
      'error'
    end

    def response_success_handle
      'success'
    end

    def json_response?
      response_headers_hash['content_type'].to_s =~ /json/
    end

    def build_response
      @meta.status_code      = response_obj.code
      @meta.response         = json_safe_parse(response_obj.body)
      @meta.response_headers = response_obj.headers

      @meta.response_valid = !!response_status_check
      @meta.response_data  = response_valid ? response_success_handle : response_error_handle
    end
  end
end
