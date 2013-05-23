class QueriesController < ApplicationController

	def index
		@resultset = ""
	end

	def query
		sql = params['sql']
		results = QueryDb.connection.execute(sql)

		i = 0
		detail = "<table>"
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

		render 'index'
	end

end