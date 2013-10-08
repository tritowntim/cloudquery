class AddDatabaseIdtoMetadata < ActiveRecord::Migration
  def change
    add_reference :metadata, :database
  end
end
