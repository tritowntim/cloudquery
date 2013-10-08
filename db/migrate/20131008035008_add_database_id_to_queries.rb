class AddDatabaseIdToQueries < ActiveRecord::Migration
  def change
    add_reference :queries, :database
  end
end
