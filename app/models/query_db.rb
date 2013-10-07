class QueryDb < ActiveRecord::Base
  self.abstract_class = true

  def self.get_connection(database_conn_name)
    establish_connection database_conn_name
    self.connection
  end
end
