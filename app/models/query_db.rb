class QueryDb < Sequel::Model # ActiveRecord::Base
  self.abstract_class = true
  establish_connection "query_db"
end