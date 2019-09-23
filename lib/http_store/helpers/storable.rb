module HttpStore
  module Helpers
    module Storable
      STRING_LIMIT_SIZE = 30_000

      def storeable_record
        return unless HttpStore.config.store_enable

        @storeable_model ||= HttpStore.config.store_class.find_by(request_digest: request_digest, response_valid: true)
      end

      # you can rewrite this callback, to store the request
      def store_request
        return unless HttpStore.config.store_enable

        HttpStore.config.store_class.new(storable_meta).save
      end

      def storable_meta
        @storable_meta ||= gen_storable_meta
      end

      def gen_storable_meta
        @meta.slice(*HttpStore::STORE_KEYS).map do |k, v|
          [k, v.is_a?(Hash) || v.is_a?(Array) ? storable(v).to_json[0..STRING_LIMIT_SIZE] : v]
        end.to_h
      end

      def storable(value)
        case value
        when Hash
          value.map { |k, v| [k, storable(v)] }.to_h
        when Array
          value.map { |v| storable(v) }
        when String
          json = JSON.parse(v) rescue nil
          json ? storable(json) : storable_string(v)
        else
          v.try(:to_h) || v.try(:to_a) || v
        end
      end

      def storable_string(str)
        str.length > STRING_LIMIT_SIZE ? { digest: Digest::SHA1.hexdigest(str), origin: str[0..1000] } : str
      end
    end
  end
end
