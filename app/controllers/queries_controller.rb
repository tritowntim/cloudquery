class QueriesController < ApplicationController
  before_action :table_list

  def show
    # TODO: run query and display resultset like the default view
    # TODO: query.original_query_id to show original query ID
    # TODO: if resultset has been saved, display saved resultset
    find_database
    @query = Query.find(params[:id])
    manage_query
  end

  # TODO: load last query into text field
  def new
    find_database
    @query = @database.queries.new
    @resultset = nil
    @results_count = 0
    @table_row_counted_at = nil
  end

  def index
    find_database
    @queries = Query.where(database_id: @database.id).order('created_at DESC').limit(20)
  end

  def create
    find_database
    @query = @database.queries.new(new_query_params)

    if @query.save
      redirect_to database_query_url(@database, @query)
    end
  end

  def update
    find_database
    @query = Query.find(params[:id])

    if @query.update_attributes(edit_query_params)
      redirect_to database_queries_url(@database.id)
    end
  end

  private

  def manage_query
    sql = @query.sql_text

    @results = execute_query(sql)

    @query.record_count = @results['detail'].count
    @query.save

    @new_query = Query.new
    @new_query.sql_text = sql
  end

  def execute_query(sql)
    query_begin = Time.now.strftime('%s%3N').to_i
    puts "DB QUERY BEGIN  #{Time.now}  #{}"
    results = QueryDb.get_connection(@database.id).execute(sql)
    puts "DB QUERY END  #{Time.now}  #{Time.now.strftime('%s%3N')}"
    query_end = Time.now.strftime('%s%3N').to_i
    @query.duration_ms = query_end - query_begin

    table_oid = oid_table_name

    resultset = {}
    resultset['header'] = []
    header = resultset['header']

    results.fields().each_index do |i|
      head = {}
      head['column_name'] = results.fname(i)
      head['table_name'] = table_oid[results.ftable(i)]
      head['data_type'] = QueryDb.get_connection(@database.id).execute("SELECT format_type(#{results.ftype(i)}, #{results.fmod(i)})").getvalue(0,0)
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
    pg_class = QueryDb.get_connection(@database.id).execute("SELECT relname, oid FROM pg_class")
    pg_class.each do |c|
      lookup[c['oid'].to_i] = c['relname']
    end
    lookup
  end

  def new_query_params
    params.require(:query).permit(:sql_text)
  end

  def edit_query_params
    params.require(:query).permit(:notes)
  end

  def table_list
    @table_list = Metadata.list_tables(params[:database_id])
  end

  def find_database
    @database = Database.friendly.find(params[:database_id])
  end
end
