require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    "#{@class_name.underscore}s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name = options[:class_name] || name.to_s.capitalize.singularize
    @foreign_key = options[:foreign_key] || "#{@class_name.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] || name.to_s.capitalize.singularize
    @foreign_key = options[:foreign_key] || "#{self_class_name.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    temp = BelongsToOptions.new(name, options)
    self.assoc_options[name] = temp
    define_method(name) do
      options = self.class.assoc_options[name]
      val = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => val).first
    end
  end

  def has_many(name, options = {})
    temp = HasManyOptions.new(name, self.name, options)
    self.assoc_options[name] = temp

    define_method(name) do
      options = self.class.assoc_options[name]
      val = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => val)
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
