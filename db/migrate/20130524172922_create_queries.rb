class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.text :sql_text

      t.timestamps
    end
  end
end
