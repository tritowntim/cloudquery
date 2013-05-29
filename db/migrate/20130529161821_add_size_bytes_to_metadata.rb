class AddSizeBytesToMetadata < ActiveRecord::Migration
  def change
    add_column :metadata, :size_bytes, :bigint
  end
end
