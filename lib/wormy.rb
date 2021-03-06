require 'active_support/inflector'
require 'wormy/db_connection'
require 'wormy/searchable'
require 'wormy/associatable'

module WORMY
  class Base
    extend Searchable
    extend Associatable

    def self.all
      results = DBConnection.execute(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
      SQL

      parse_all(results)
    end

    def self.columns
      @columns ||= DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
      SQL
      .first.map(&:to_sym)
    end

    def self.count(params)
      where(params).count
    end

    def self.destroy_all(params)
      self.where(params).each(&:destroy)
    end

    def self.finalize!
      # make sure to call finalize! at the end of any class that inherits from WORMY::Base
      columns.each do |col|
        define_method(col) { attributes[col] }
        define_method("#{col}=") { |new_attr| attributes[col] = new_attr }
      end
    end

    def self.find(id)
      result = DBConnection.execute(<<-SQL, id)
        SELECT
          *
        FROM
          #{table_name}
        WHERE
          #{table_name}.id = ?
      SQL

      parse_all(result).first
    end

    def self.first
      all.first
    end

    def self.last
      all.last
    end

    def self.parse_all(results)
      # create new instances of self from the query results
      results.map { |options| self.new(options) }
    end

    def self.table_name
      @table_name ||= self.to_s.tableize
    end

    def self.table_name=(table_name)
      @table_name = table_name
    end

    def self.validates(*methods)
      @validations = methods
    end

    def self.validations
      @validations ||= []
    end

    def attributes
      @attributes ||= {}
    end

    def attribute_values
      # look at all the columns and get the values for this instance
      self.class.columns.map { |col| self.send(col) }
    end

    def initialize(params = {})
      params.each do |key, value|
        raise "unknown attribute '#{key}'" unless self.class.columns.include?(key.to_sym)
        send("#{key}=", value)
      end
    end

    def destroy
      if self.class.find(id)
        DBConnection.execute(<<-SQL)
          DELETE
          FROM
            #{self.class.table_name}
          WHERE
            id = #{id}
        SQL

        self
      end
    end

    def insert
      col_names = self.class.columns.join(", ")
      question_marks = ["?"] * self.class.columns.count

      DBConnection.execute(<<-SQL, *attribute_values)
        INSERT INTO
          #{self.class.table_name} (#{col_names})
        VALUES
          (#{question_marks.join(',')})
      SQL

      self.id = DBConnection.last_insert_row_id
    end

    def save
      self.class.validations.each do |method|
        raise "Validation error" unless self.send(method)
      end

      # if it alredy exists then update it, otherwise insert it
      id ? update : insert
    end

    def update
      set = self.class.columns.map { |col_name| "#{col_name} = ?" }.drop(1).join(", ")

      DBConnection.execute(<<-SQL, *attribute_values.rotate)
        UPDATE
          #{self.class.table_name}
        SET
          #{set}
        WHERE
          id = ?
      SQL
    end

    def valid?
      self.class.validations.each do |method|
        return false unless self.send(method)
      end

      true
    end
  end
end
