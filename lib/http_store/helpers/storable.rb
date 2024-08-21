module HttpStore
  module Helpers
    module Storable
      STRING_LIMIT_SIZE = 1000
      TEXT_LIMIT_SIZE   = 10000

      def storeable_record
        return unless HttpStore.config.store_enable

        expired_time      = Time.current - HttpStore.config.store_time
        @storeable_record ||= store_class.where('created_at > ?', expired_time).where(request_digest: @meta.request_digest, cache_response: true).order(id: :desc).first
      end

      def load_storeable_record
        return if storeable_record.nil?

        attrs =
          storeable_record.attributes.slice(*HttpStore::ALL_KEYS).map do |k, v|
            [k, v.is_a?(String) ? json_safe_parse(v) : v]
          end.to_h

        @meta.reverse_merge! attrs
        @meta.parent_id = storeable_record.id
      end

      # you can rewrite this callback, to store the request
      def store_request(save_now = true)
        return unless HttpStore.config.store_enable

        if save_now
          @storeable_record = store_class.new(gen_storable_meta)
          @storeable_record.save!
        else
          @meta.parent_id = storeable_record.id if use_cache?
          HttpStore::Job::HttpLogStoreJob.perform_later(gen_storable_meta)
        end
      end

      def store_class
        @store_class ||= HttpStore.config.store_class.to_s.constantize
      end

      def use_cache?
        @use_cache ||= !@meta.force && storeable_record.present?
      end

      def gen_storable_meta
        @meta.slice(*HttpStore::STORE_KEYS).map do |k, v|
          storable_v = storable(v)

          begin
            storable_v = storable_v.to_json[0..TEXT_LIMIT_SIZE] if v.is_a?(Hash) || v.is_a?(Array)

            [k, storable_v]
          rescue JSON::GeneratorError
            [k, storable_v.to_s[0..TEXT_LIMIT_SIZE]]
          end
        end.to_h
      end

      def storable(value)
        case value
        when Hash
          value.map { |k, v| [k, storable(v)] }.to_h
        when Array
          value.map { |v| storable(v) }
        when String
          json = JSON.parse(value) rescue nil
          json ? storable(json) : storable_string(value)
        when TrueClass, FalseClass, NilClass, Numeric
          value
        else
          storable_string(value.to_s)
        end
      end

      def storable_string(str)
        str = str.dup.force_encoding("UTF-8")
        raise EncodingError unless str.encoding.name == 'UTF-8'
        raise EncodingError unless str.valid_encoding?

        str.length > STRING_LIMIT_SIZE ? { digest: Digest::SHA1.hexdigest(str), origin: str[0..STRING_LIMIT_SIZE] } : str
      rescue EncodingError
        { digest: Digest::SHA1.hexdigest(str) }
      end

      def json_safe_parse(str)
        JSON.parse(str) rescue str
      end
    end
  end
end
