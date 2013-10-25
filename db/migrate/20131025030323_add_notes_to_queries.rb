class AddNotesToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :notes, :text
  end
end
