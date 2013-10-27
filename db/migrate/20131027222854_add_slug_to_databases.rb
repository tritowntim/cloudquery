class AddSlugToDatabases < ActiveRecord::Migration
  def change
    add_column :databases, :slug, :string, length: 50
  end
end
