class CreateMetadata < ActiveRecord::Migration
  def change
    create_table :metadata do |t|
      t.string :object_type
      t.text :schema
      t.text :name
      t.integer :record_count

      t.timestamps
    end
  end
end
