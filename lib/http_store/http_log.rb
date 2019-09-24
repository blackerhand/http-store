module HttpStore
  class HttpLog < ActiveRecord::Base
    belongs_to :requestable, polymorphic: true, optional: true

    has_many :sons, class_name: 'HttpStore::HttpLog', foreign_key: 'parent_id', optional: true
    belongs_to :parent, class_name: 'HttpStore::HttpLog', optional: true
  end
end
