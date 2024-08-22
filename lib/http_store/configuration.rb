module HttpStore
  class Configuration
    attr_writer :store_enable, :store_class, :store_time, :store_job_enable

    def store_enable
      @store_enable || true
    end

    def store_class
      @store_class || HttpStore::HttpLog
    end

    def store_time
      @store_time || 31_536_000
    end

    def store_job_enable
      @store_job_enable || false
    end
  end
end
