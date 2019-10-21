class AddCacheResponseFieldToHttpLog < ActiveRecord::Migration[5.2]
  def change
    add_column :http_logs, :cache_response, :boolean
    add_column :http_logs, :response_code, :integer
  end
end
