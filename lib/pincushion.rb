require 'set'
require 'pincushion/plugins'

module Pincushion
  def self.from_rows(rows)
    Module.new.module_eval do
      include Pincushion

      predicates = rows
                   .reduce(Set.new) { |a, e| a.merge(e.keys) }
                   .delete(:identifier)
      predicates(*predicates)

      rows.each do |row|
        row = row.dup
        identifier = row.delete(:identifier)
        true_predicates = row.each_pair.select { |_, v| v }.map { |k, _| k }
        that_is(*true_predicates).named(identifier)
      end

      self
    end
  end

  def self.validate(mod, preds)
    violations = Set.new(preds) - mod.predicates
    return if violations.empty?
    fail MissingPredicateError,
         "Tried to set a value for unregistered predicate(s): "\
         "#{violations.inspect}"
  end

  module RootModuleMethods
    include Plugins

    attr_reader :identifiers

    def rows
      identifiers.map do |id, cls|
        { identifier: id }.merge(cls.new(id).all_predicates_hash)
      end
    end

    def find(identifier)
      unless identifiers.key?(identifier)
        fail MissingIdentifierError, "Can't find model #{identifier.inspect}"
      end

      identifiers[identifier].new(identifier)
    end

    def predicates(*preds)
      return (@predicates || Set.new) if preds.empty?
      fail "Predicates can't be changed after initialization" if @predicates
      @predicates = Set.new(preds)
      is_not(*@predicates)
      @predicates.each do |predicate|
        alias_method(:"is_#{predicate}?", :"#{predicate}?")
      end
    end
  end # module RootModuleMethods

  module ModuleMethods
    attr_reader :predicate_pincushion_root

    def all_predicates
      predicate_pincushion_root.predicates
    end

    def all_predicates_hash
      obj = new ""
      Hash[predicate_pincushion_root.predicates.map { |p| [p, obj.is?(p)] }]
    end

    def identifiers
      predicate_pincushion_root.identifiers
    end

    def is(*preds)
      Pincushion.validate(predicate_pincushion_root, preds)
      preds.each { |pred| define_method(:"#{pred}?") { true } }
      self
    end

    def is_not(*preds)
      Pincushion.validate(predicate_pincushion_root, preds)
      preds.each { |pred| define_method(:"#{pred}?") { false } }
      self
    end

    def named(*given_identifiers)
      given_identifiers.each do |id|
        if identifiers.key?(id)
          fail DuplicateIdentifierError,
               "Identifier #{id} not unique: #{identifiers[id]} <> #{self}"
        end

        identifiers[id] = self
      end

      self
    end

    def that_are(*preds)
      Pincushion.validate(self, preds)
      base = self
      mod = Module.new { include base }
      mod.is(*preds)
      mod
    end

    def that_is(*preds)
      Pincushion.validate(self, preds)
      base = self
      klass = Class.new { include base }
      klass.is(*preds)
      klass
    end

    def included(mod)
      base = self

      mod.instance_eval do
        @predicate_pincushion_root = base.predicate_pincushion_root
        extend ModuleMethods
        include InstanceMethods
      end
    end
  end # module ModuleMethods

  module InstanceMethods
    attr_reader :name

    def initialize(name, *_)
      @name = name
      @additional_predicates = Set.new
    end

    def all_predicates
      self.class.all_predicates.merge(@additional_predicates)
    end

    def all_predicates_hash
      Hash[all_predicates.map { |p| [p, is?(p)] }]
    end

    def is(*preds)
      preds.each do |pred|
        define_singleton_method(:"#{pred}?") { true }
        @additional_predicates << pred
      end

      self
    end

    def is_not(*preds)
      preds.each do |pred|
        define_singleton_method(:"#{pred}?") { false }
        @additional_predicates << pred
      end

      self
    end

    def is?(predicate)
      unless all_predicates.include?(predicate)
        fail MissingPredicateError, "Unknown predicate #{predicate}"
      end

      send(:"#{predicate}?")
    end

    def any?(*preds)
      preds.any? { |pred| is?(pred) }
    end

    def all?(*preds)
      preds.all? { |pred| is?(pred) }
    end
  end # module InstanceMethods

  def self.included(mod)
    mod.instance_eval do
      @identifiers = {}
      @predicate_pincushion_root = self

      extend ModuleMethods
      extend RootModuleMethods
      include InstanceMethods

      is_not(*predicates)
    end
  end

  DuplicateIdentifierError = Class.new(StandardError)
  MissingIdentifierError = Class.new(StandardError)
  MissingPredicateError = Class.new(StandardError)
end # module Pincushion
