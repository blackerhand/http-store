class AddIndexToHttpLog < ActiveRecord::Migration[5.2]
  def change
    add_index :http_logs, :client_type
  end
end
