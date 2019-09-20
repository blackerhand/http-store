module HttpStore
  class InitializerGenerator < Rails::Generators::Base
    def create_initializer_file
      create_file "config/initializers/http_store.rb", <<FILE
# HttpStore Config
HttpStore.configure do
end
FILE

    end
  end
end
