module HttpStore
  module Job
    class HttpLogStoreJob < ::ActiveJob::Base
      queue_as :default

      def perform(meta)
        @storeable_record = HttpStore.config.store_class.new(meta)
        @storeable_record.save!
      end
    end
  end
end
