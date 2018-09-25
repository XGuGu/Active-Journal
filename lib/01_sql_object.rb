require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'


class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
     SELECT *
     FROM #{self.table_name}
    SQL

  end

  def self.finalize!
    self.columns.each do |method_name|

     define_method(method_name) do
       self.attributes[method_name]
     end

     define_method("#{method_name}=") do |val|
       self.attributes[method_name] = val
     end

   end
  end

  def self.table_name=(table)
    @table_name = table
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    result = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL

    self.parse_all(result)

  end

  def self.parse_all(results)
    results.map{ |h| self.new(h) }
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL
    # debugger
    return nil if result.empty?
    self.new(result[0])
  end

  def initialize(params = {})
    params.each do |key, val|

      if self.class.columns.include?(key.to_sym)
        self.send("#{key}=", val)
      else
        raise "unknown attribute '#{key}'"
      end

    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.keys.map{ |k| @attributes[k] }
  end

  def insert
    length = self.class.columns[1..-1].length
    col_names = '(' + self.class.columns[1..-1].join(',') + ')'
    question_marks = '(' + (['?'] * length).join(',') + ')'

    table = DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name}#{col_names}
      VALUES
        #{question_marks}
    SQL

    send('id=', DBConnection.last_insert_row_id)
  end

  def update
    col_names = self.class.columns[1..-1].map{ |col| "#{col} = ?"}.join(',')
    # debugger

    table = DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        id = #{self.id}
    SQL
  end

  def save
    if self.id == nil
      self.insert
    else
      self.update
    end
  end
end
