require_relative 'db_connection'
require_relative 'base'

module Searchable
  def where(params = {})
    return all if params == {}

    search_results = []
    where_line = params.keys.map { |key| "#{key} = ?" }.join(" AND ")

    results = WORM::DBConnection.execute(<<-SQL, *params.values)
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
