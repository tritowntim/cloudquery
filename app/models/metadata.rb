class Metadata < ActiveRecord::Base
  belongs_to :database

    def self.list_tables(database_id)
      tables = QueryDb.get_connection(database_id).execute(sql_all_tables)
      tables.each do |table|
        Metadata.find_or_create_by(name: table['table_name'], object_type: 'table', schema: 'public', database_id: database_id)
      end
      Metadata.where(database_id: database_id)
    end

    def self.get_table_stats(database_id)
      list_tables(database_id).each do |table|
        table.record_count = QueryDb.get_connection(database_id).execute("SELECT COUNT(1) FROM #{table.name}")[0]['count']
        table.size_bytes = QueryDb.get_connection(database_id).execute("SELECT PG_TOTAL_RELATION_SIZE('#{table.name}')")[0]['pg_total_relation_size']
        table.touch
        table.save
      end
    end

    def self.sql_all_tables
      "SELECT * FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name"
    end

    def self.all_databases
      Rails.configuration.database_configuration.keys.select { |key| ! %w{defaults test query_db}.include? key }
    end
end
