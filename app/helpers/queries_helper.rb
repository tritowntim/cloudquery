module QueriesHelper

  def resultset_header_row_datasource_table_name(header)
    content_tag :tr, class: 'metadata' do
      safe_concat(resultset_header_row_datasource_table_cell '', 1)
      colspans = calculate_colspans(header)
      colspans.each do |table_name, colspan|
        safe_concat resultset_header_row_datasource_table_cell(table_name, colspan)
      end
    end
  end

  def calculate_colspans(header)
    header.chunk { |h| h['table_name'] ? h['table_name'] : '~ calculated ~' }.map { |k,v| [k,v.length] }
  end

  def resultset_header_row_datasource_table_cell(table_name, colspan)
    content_tag :th, colspan: colspan do
      table_name
    end
  end

end
