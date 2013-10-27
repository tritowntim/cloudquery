class QueryDb < ActiveRecord::Base
  self.abstract_class = true

  def self.get_connection(database_id)
    establish_connection Database.friendly.find(database_id).name
    self.connection
  end
end
