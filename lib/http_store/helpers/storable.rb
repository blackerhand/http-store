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
          [k, v.is_a?(Hash) ? storable_hash(v).to_json[0..STRING_LIMIT_SIZE] : v]
        end.to_h
      end

      def storable_hash(hash)
        hash.map do |k, v|
          [k, case v
              when Hash
                storable_hash(v)
              when String
                storable_string(v)
              when Class
                v.to_s
              else
                v
              end
          ]
        end.to_h
      end

      def storable_string(str)
        str.length > STRING_LIMIT_SIZE ? { digest: Digest::SHA1.hexdigest(str), origin: str[0..1000] } : str
      end
    end
  end
end
