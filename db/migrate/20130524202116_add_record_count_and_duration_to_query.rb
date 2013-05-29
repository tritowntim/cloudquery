class AddRecordCountAndDurationToQuery < ActiveRecord::Migration
  def change
    add_column :queries, :record_count, :integer
    add_column :queries, :duration_ms, :integer
  end
end
