class QueriesController < ApplicationController
  before_action :default_db, :list_db

	# include ActionView::Helpers::NumberHelpers
	# respond_to :html, :json

	def show
		@original_query = Query.find(params[:id])
		@query = Query.new(sql_text: @original_query.sql_text)
		manage_query
		# TODO: run query and display resultset like the default view
		# TODO: query.original_query_id to show original query ID
		# TODO: if resultset has been saved, display saved resultset
	end

	def recent
		@queries = Query.where(db: @db_name).order('created_at DESC').limit(50)
	end

	def all
		@queries = Query.order('created_at DESC')
	end


	def index
		@query = Query.new
		@resultset = nil
		@results_count = 0
		@table_list = Metadata.list_tables(@db_name)

		@table_row_counted_at = nil
	end

	def create
		@query = Query.new(query_params)
		manage_query
	end

	private

	def manage_query
		sql = @query.sql_text

		@results = execute_query(sql)

		@query.record_count = @results['detail'].count
		@query.db = @db_name
		@query.save

		@new_query = Query.new
		@new_query.sql_text = sql

		@table_list = Metadata.list_tables(@db_name)

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

	def execute_query(sql)
		query_begin = Time.now.strftime('%s%3N').to_i
		puts "DB QUERY BEGIN  #{Time.now}  #{}"
		results = QueryDb.get_connection(@db_name).execute(sql)
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
			head['data_type'] = QueryDb.get_connection(@db_name).execute("SELECT format_type(#{results.ftype(i)}, #{results.fmod(i)})").getvalue(0,0)
			header << head
		end

		resultset['detail'] = []
		detail = resultset['detail']

  	results.each_row do |row|
 			det = {}
 			i = 0
	    row.each do |v|
	    	det["#{i}"] = v.to_s
	    	i = i + 1
	    end
			detail << det
		end

		resultset
	end

		def oid_table_name
			lookup = {}
			pg_class = QueryDb.get_connection(@db_name).execute("SELECT relname, oid FROM pg_class")
			pg_class.each do |c|
				lookup[c['oid'].to_i] = c['relname']
			end
			lookup
		end

		def query_params
	    params.require(:query).permit(:id, :sql_text, :duration_ms, :record_count)
		end
end
