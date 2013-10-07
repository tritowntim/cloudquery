class AddDbToQuery < ActiveRecord::Migration
  def change
    add_column :queries, :db, :string
  end
end
