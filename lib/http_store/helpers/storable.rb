module HttpStore
  module Helpers
    module Storable
      STRING_LIMIT_SIZE = 30_000

      def storeable_record
        return unless HttpStore.config.store_enable

        @storeable_record ||= HttpStore.config.store_class.where(request_digest: @meta.request_digest, cache_response: true).order(id: :desc).first
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
      def store_request
        return unless HttpStore.config.store_enable

        @meta.parent_id   = storeable_record.id if use_cache?
        @storeable_record = HttpStore.config.store_class.new(gen_storable_meta)
        @storeable_record.save!
      end

      def use_cache?
        @use_cache ||= !@meta.force && storeable_record.present?
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
          json = JSON.parse(value) rescue nil
          json ? storable(json) : storable_string(value)
        else
          value.try(:to_h) || value.try(:to_a) || value
        end
      end

      def storable_string(str)
        str.length > STRING_LIMIT_SIZE ? { digest: Digest::SHA1.hexdigest(str), origin: str[0..1000] } : str
      end

      def json_safe_parse(str)
        JSON.parse(str) rescue str
      end
    end
  end
end
