class AddPgExceptionColumnsToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :pg_exception_class, :string, length: 255
    add_column :queries, :pg_exception, :text
  end
end
