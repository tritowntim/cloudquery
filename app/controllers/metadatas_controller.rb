class MetadatasController < ApplicationController

	def index
		@metadatas = Metadata.order(:size_bytes).reverse
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

		@cols = QUERY_DB[sql].all
	end

end