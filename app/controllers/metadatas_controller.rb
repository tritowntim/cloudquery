class MetadatasController < ApplicationController

  # TODO: support all metadatas, perhaps with route not nested within database (?)
  def index
    find_database
    @metadatas = @database.metadatas.order('size_bytes DESC')
  end

  # TODO: restore columns support
  def columns
    sql = <<-SQL
          SELECT c.table_name, c.column_name, c.ordinal_position,
                 c.is_nullable, c.data_type, c.character_maximum_length
            FROM information_schema.tables t
      INNER JOIN information_schema.columns c ON t.table_name = c.table_name
           WHERE t.table_schema = 'public' AND table_type = 'BASE TABLE'
        ORDER BY c.table_name, c.ordinal_position
    SQL

    @cols = QueryDb.connection.execute(sql)
  end

  # TODO: accessible via rake task for scheduling some day
  def refresh
    find_database
    Metadata.get_table_stats(@database.id)
    redirect_to action: :index
  end

  private

  def find_database
    @database = Database.friendly.find(params['database_id'])
  end
end
