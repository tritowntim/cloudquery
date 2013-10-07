class AddDbToMetadata < ActiveRecord::Migration
  def change
    add_column :metadata, :db, :string
  end
end
