class Metadata < Sequel::Model # ActiveRecord::Base
  set_allowed_columns :name, :object_type, :record_count, :schema, :size_bytes
end
