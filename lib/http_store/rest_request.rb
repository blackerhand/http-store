# == Schema Information
#
# Table name: rest_requests
#
#  id               :integer          not null, primary key
#  http_method      :string(255)
#  url              :string(255)
#  headers          :text(65535)
#  query_params     :text(65535)
#  data_type        :string(255)
#  data             :text(65535)
#  status_code      :integer
#  response         :text(65535)
#  response_headers :text(65535)
#  response_status  :boolean
#  response_data    :text(65535)
#  type             :string(255)
#  requestable_id   :string(255)
#  requestable_type :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  request_data     :text(65535)
#  is_valid         :boolean
#

module HttpStore
  class RestRequest < ActiveRecord::Base
    include HttpStore::Requestable
    include HttpStore::Responseable

    belongs_to :requestable, polymorphic: true, optional: false

    def self.execute(attrs, &block)
      req = new(attrs)
      req.build_request
      req.default_request
      req.is_valid = req.request_valid?
      req.save! # save request

      req.execute(&block) if req.is_valid
      req
    end

    def http_get_execute
      RestClient.get("#{url}?#{query_params_hash.to_query}", headers_hash)
    rescue RestClient::ExceptionWithResponse => e
      # :nocov:
      e.response
      # :nocov:
    end

    def http_post_execute
      real_data = json_request? ? data_hash.to_json : data_hash.to_hash
      RestClient.post("#{url}?#{query_params_hash.to_query}", real_data, headers_hash.to_hash.symbolize_keys)
    rescue RestClient::ExceptionWithResponse => e
      # :nocov:
      e.response
      # :nocov:
    end

    def execute
      self.response_obj = get? ? http_get_execute : http_post_execute
      raise RestRequestError, 'response_obj is nil' unless response_obj

      save_response
      save_response_result

      yield self if block_given?

      self
    end

    %i[query_params_hash data_hash headers_hash request_data_hash
     response_hash response_data_hash response_headers_hash].each do |hash_key|
      define_method hash_key do
        iv_key = "@#{hash_key}".to_sym

        result =
          if instance_variable_get(iv_key).present?
            instance_variable_get(iv_key)
          else
            json_field = hash_key.to_s.gsub(/_hash/, '').to_sym
            instance_variable_set iv_key, (JSON.parse(send(json_field)) rescue {})
          end

        Hashie::Mash.new(result) rescue Hashie::Mash.new({})
      end
    end
  end
end
