class QueriesController < ApplicationController
  before_action :table_list
  respond_to :html, :json, :js

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

  def edit
    find_database
    @query = Query.find(params[:id])
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
      respond_to do |format|
        format.html { redirect_to database_queries_url(@database.id) }
        format.js
      end
    end
  end

  private

  def manage_query
    sql = @query.sql_text

    @results = execute_query(sql)

    @query.save

    @new_query = Query.new
    @new_query.sql_text = sql
  end

  def execute_query(sql)
    DataType.load_all

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
      head['data_type'] = DataType.lookup(results.ftype(i), results.fmod(i))
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

    @query.record_count = resultset['detail'].count

    resultset

    rescue => e

      @query.pg_exception_class = e.original_exception.class.to_s
      @query.pg_exception = e.original_exception.to_s
      @query.duration_ms = nil
      @query.record_count = nil

      empty_resultset = {}
      empty_resultset['header'] = []
      empty_resultset['detail'] = []
      empty_resultset
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
    @table_list = Metadata.list_tables(Database.friendly.find(params[:database_id]).id)
  end

  def find_database
    @database = Database.friendly.find(params[:database_id])
  end
end
