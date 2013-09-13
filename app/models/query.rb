class Query < Sequel::Model # ActiveRecord::Base
  set_allowed_columns :sql_text
end
