
class QueriesController < ApplicationController

	# include ActionView::Helpers::NumberHelpers
	# respond_to :html, :json

	def show
		@query = Query.find(params[:id])
	end

	def recent
		@queries = Query.order('created_at DESC').limit(50)
		load_tables
	end

	def all
		@queries = Query.order('created_at DESC')
	end

	def index
		@query = Query.new
		@resultset = nil
		@results_count = 0
		@table_list = db_tables.html_safe
 		
 		# refresh = params[:force] == 'true'  
 		# puts refresh
 		# @table_row_count = count_table_row(refresh)
		# @table_row_counted_at = table_row_count_time 
		@table_row_counted_at = nil
		# load_tables
	end

	def create
		@query = Query.new(params[:query])
		sql = @query.sql_text

		query_begin = Time.now.strftime('%s%3N').to_i
		puts "DB QUERY BEGIN  #{Time.now}  #{}"
		results = QueryDb.connection.execute(sql)
		puts "DB QUERY END  #{Time.now}  #{Time.now.strftime('%s%3N')}"
		query_end = Time.now.strftime('%s%3N').to_i
		@query.duration_ms = query_end - query_begin

		table_oid = oid_table_name 

		resultset = {}
		resultset['header'] = []
		header = resultset['header']

	  # head['table_name'] = []
	  # head['columns_name'] = []
	  # head['data_type'] = []

		results.fields().each_index do |i| 
			head = {}
			head['column_name'] = results.fname(i)
			head['table_name'] = table_oid[results.ftable(i)]
			head['data_type'] = QueryDb.connection.execute("SELECT format_type(#{results.ftype(i)}, #{results.fmod(i)})").getvalue(0,0)
			header << head
		end

		resultset['detail'] = []
		detail = resultset['detail'] 

  	results.each do |row| 
 			det = {}
	    row.each do |k,v|
	    	det[k] = v.to_s
	    end 
			detail << det
		end

		# binding.pry
		@results = resultset

		@query.record_count = results.count
		@query.save
		@query_prev = @query

		@query = Query.new
		@query.sql_text = sql

		@results_count = results.count

		@table_list = db_tables.html_safe

		# TODO: support natively
		# render :json => @results
		if sql.index('json')
			render json: @results
		else
			respond_to do |format|
				format.html { render 'index' }
				format.json { render json: @results }
			end
		end
	end

	private

		def sql_all_tables 
			"SELECT * FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name"
		end

		def db_tables
			tables = QueryDb.connection.execute(sql_all_tables)
			table_row_counts = count_table_row(false)
			table_list = "<p>Tables</p><ul>"
			tables.each do |table|
				table_list += "<li>#{table['table_name']}"
				if Metadata.exists?(name: table['table_name'])
					c = Metadata.where(name: table['table_name']).first
					table_list += " (#{ActionController::Base.helpers.number_with_delimiter(c.record_count)})"	
				else
					table_list += " <em>N/A</em>"
				end
				table_list += "</li>"
			end
			table_list += "</ul>"
		end

		def oid_table_name
			lookup = {}
			pg_class = QueryDb.connection.execute("SELECT relname, oid FROM pg_class")
			pg_class.each do |c|
				lookup[c['oid'].to_i] = c['relname'] 
			end
			lookup
		end

		def count_table_row(force_refresh)
			Rails.cache.fetch("table_row_count", :force => force_refresh) do
				tables = QueryDb.connection.execute("SELECT * FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE '%pardot%' ORDER BY table_name")
				table_row_counts = {}
				tables.each do |table|
					puts "counting #{table['table_name']} ..."
					table_row_counts[table['table_name']] = QueryDb.connection.execute("SELECT COUNT(1) FROM #{table['table_name']}")[0]['count']
				end
				Rails.cache.write("table_row_counted_at", DateTime.now)
				table_row_counts
			end
		end

		def table_row_count_time
			Rails.cache.fetch("table_row_counted_at") do
				count_table_row(false)
				DateTime.now
			end
		end

		def load_tables
			tables = QueryDb.connection.execute(sql_all_tables)
			# Tables = {}
			tables.each do |table|
				puts "counting #{table['table_name']} ..."
				row_count = QueryDb.connection.execute("SELECT COUNT(1) FROM #{table['table_name']}")[0]['count']
				size_bytes = QueryDb.connection.execute("SELECT PG_TOTAL_RELATION_SIZE('#{table['table_name']}')")[0]['pg_total_relation_size']				
				if Metadata.exists?(name: table['table_name'])
					m = Metadata.where(name: table['table_name']).first
					m.record_count = row_count
					m.size_bytes = size_bytes
					m.save
					m.touch
				else
					Metadata.create(object_type: 'table', schema: 'public', name: table['table_name'], record_count: row_count, size_bytes: size_bytes)
				end
			end
		end

end