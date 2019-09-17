module HttpStore
  module Responseable
    attr_accessor :response_obj

    # 判断请求是否到达第三方接口, 并处理. 若为 true 不再重复调用
    def response_status_check
      status_code == 200
    end

    def json_response?
      response_headers_hash['content_type'].to_s =~ /json/
    end

    def file_response?
      response_headers_hash['content_type'].to_s =~ /(stream|file)/
    end

    def save_response
      self.status_code      = response_obj.code
      self.response         = response_obj.body if response_obj.body.size < GRAPE_API::HTTP_FILE_SIZE_LIMIT && !file_response?
      self.response_headers = response_obj.headers.to_json
      save!
    end

    def save_response_result
      self.response_status = !!response_status_check
      @response_data_hash  = response_status ? { data: rsp_success_data } : { error: rsp_error_msg }
      raise RestRequestError, '三方请求异常, 请与管理员联系' if result.blank?

      self.response_data = @response_data_hash.to_json
      save!
    end

    def result
      response_data_hash.data.presence || response_data_hash.error.presence
    end
  end
end
