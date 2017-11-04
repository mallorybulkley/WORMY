require_relative 'searchable'
require 'active_support/inflector'

class AssociationOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssociationOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name.to_s.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase
  end
end

class HasManyOptions < AssociationOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.to_s.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
  end
end

module Associatable
  def association_options
    @association_options ||= {}
  end

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      key_value = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => key_value).first
    end

    self.association_options[name] = options
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)

    define_method(name) do
      options.model_class.where(options.foreign_key => self.id)
    end

    self.association_options[name] = options
  end

  def has_one_through(association_name, through:, source:)
    define_method(association_name) do
      through_options = self.class.association_options[through]
      source_options = through_options.model_class.association_options[source]

      source_table = source_options.table_name
      through_table = through_options.table_name
      key_value = self.send(through_options.foreign_key)

      results = WORMY::DBConnection.execute(<<-SQL, key_value)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_options.foreign_key} = #{source_table}.#{source_options.primary_key}
        WHERE
          #{through_table}.#{through_options.primary_key} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end

  def has_many_through(association_name, through:, source:)
    define_method(association_name) do
      through_options = self.class.association_options[through]
      source_options = through_options.model_class.association_options[source]

      source_table = source_options.table_name
      through_table = through_options.table_name

      results = WORMY::DBConnection.execute(<<-SQL, self.id)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{source_table}.#{source_options.foreign_key} = #{through_table}.#{source_options.primary_key}
        WHERE
          #{through_table}.#{through_options.foreign_key} = ?
      SQL

      source_options.model_class.parse_all(results)
    end
  end

end
