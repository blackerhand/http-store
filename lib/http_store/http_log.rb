module HttpStore
  class HttpLog < ActiveRecord::Base
    belongs_to :requestable, polymorphic: true, optional: true

    has_many :sons, class_name: 'HttpStore::HttpLog', foreign_key: 'parent_id'
    belongs_to :parent, class_name: 'HttpStore::HttpLog'
  end
end
