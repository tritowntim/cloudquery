class CreateDataTypes < ActiveRecord::Migration
  def change
    create_table :data_types do |t|
      t.integer :ftype
      t.integer :fmod
      t.string :description

      t.timestamps
    end
  end
end
