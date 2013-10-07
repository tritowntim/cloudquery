class MetadatasController < ApplicationController
  before_action :default_db, :list_db

	def index
		if params['db_name'] == 'all'
			@metadatas = Metadata.order('size_bytes DESC')
		else
			@metadatas = Metadata.where(db: params['db_name']).order('size_bytes DESC')
		end
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
  	db_name = params['db_name']
		if db_name == 'all'
			Metadata.all_databases.each { |database| Metadata.get_table_stats(database) }
    else
    	Metadata.get_table_stats(db_name)
  	end
    redirect_to action: :index
  end
end
