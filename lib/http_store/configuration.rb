module HttpStore
  class Configuration
    attr_writer :store_enable, :store_class

    def store_enable
      @store_enable || true
    end

    def store_class
      @store_class || HttpStore::HttpLog
    end
  end
end
