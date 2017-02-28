require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    search_results = []
    where_line = params.keys.map { |key| "#{key} = ?" }.join(" AND ")

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    results.each { |result| search_results << self.new(result) }

    search_results
  end
end
