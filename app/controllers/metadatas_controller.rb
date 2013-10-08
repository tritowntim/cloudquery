class MetadatasController < ApplicationController
  before_action :default_db, :list_db

	def index

		# if params['db_name'] == 'all'
		# 	@metadatas = Metadata.order('size_bytes DESC')
		# else
    @database = Database.find(params['database_id'])
		@metadatas = @database.metadatas.order('size_bytes DESC')
		# end
	end

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

  def refresh
    @database = Database.find(params['database_id'])
		Metadata.get_table_stats(@database.id)
    redirect_to action: :index
  end
end
