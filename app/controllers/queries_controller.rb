class QueriesController < ApplicationController

	def index
		@resultset = nil
		@results_count = 0
		@table_list = db_tables.html_safe
	end

	def query
		@sql = params['sql']
		results = QueryDb.connection.execute(@sql)

		table_oid = oid_table_name

		header = "<thead><tr><th/>"
		types = "<tr><th/>"
		results.fields().each_index do |i| 
		    header += "<th>#{table_oid[results.ftable(i)]}<br>#{results.fname(i).upcase}</th>"
		    c = QueryDb.connection.execute("SELECT format_type(#{results.ftype(i)}, #{results.fmod(i)})").getvalue(0,0)
		    types += "<td><em>#{c}</em></td>"
		end

		header += "</tr>"
		types += "</tr></thead>"

		i = 0
		detail = "<table>" + header + types
  	results.each do |row|
 			detail += "<tr>"
			detail += "<td>#{i+=1}</td>"
	    results.fields().each do |col|
	    	detail += "<td>#{row[col].to_s}</td>"
	    end 
			detail += "</tr>"
		end
		detail += "</table>"

		@resultset = detail.html_safe
		@results_count = i

		@table_list = db_tables.html_safe

		render 'index'
	end

	private
		def db_tables
			tables = QueryDb.connection.execute("SELECT * FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name")
			table_list = "<p>Tables</p><ul>"
			tables.each do |table|
				table_list += "<li>#{table['table_name']}</li>"
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

end