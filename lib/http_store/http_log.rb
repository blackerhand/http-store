module HttpStore
  class HttpLog < ActiveRecord::Base
    belongs_to :requestable, polymorphic: true, optional: true
  end
end
