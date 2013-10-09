class RemoveDbFromTables < ActiveRecord::Migration
  def change
    remove_column :metadata, :db, :string
    remove_column :queries, :db, :string
  end
end
