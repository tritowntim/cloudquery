class Metadata < ActiveRecord::Base
  attr_accessible :name, :object_type, :record_count, :schema
end
