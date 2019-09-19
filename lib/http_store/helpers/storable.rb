module HttpStore
  module Helpers
    module Storable
      STRING_LIMIT_SIZE = 30_000
      STORE_KEYS        = HttpStore::Client::META_KEYS - %w[response_obj requestable]

      # you can rewrite this callback, to store the request
      def store_request
        return if other_params.store_class == false

        (other_params.store_class || HttpStore::HttpLog).new(storable_meta).save
      end

      def storable_meta
        @storable_meta ||= gen_storable_meta
      end

      def gen_storable_meta
        @meta.slice(*STORE_KEYS).map do |k, v|
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
              else
                v
              end
          ]
        end.to_h
      end

      def storable_string(str)
        { digest: Digest::SHA1.hexdigest(str), origin: str[0..1000] } if str.length > STRING_LIMIT_SIZE
      end
    end
  end
end
