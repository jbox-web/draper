# frozen_string_literal: true

require "active_support/concern"
require "request_store"

require "draper/view_context"
require "draper/decorator"
require "draper/version"

module Draper
  require "draper/engine" if defined?(Rails)

  class UninferrableDecoratorError < NameError
    def initialize(klass, decorator)
      super("Could not infer a decorator for #{klass}. Looked for #{decorator}.")
    end
  end

  def self.configure
    yield self
  end

  def self.default_controller
    @default_controller ||= ApplicationController
  end

  def self.default_controller=(controller)
    @default_controller = controller
  end

  def self.decorate(object_or_enumerable, with: nil, namespace: nil)
    return object_or_enumerable unless decorable?(object_or_enumerable)

    object_or_enumerable = _decorate(object_or_enumerable, with: with, namespace: namespace)

    block_given? ? yield(object_or_enumerable) : object_or_enumerable
  end

  def self._decorate(object_or_enumerable, with: nil, namespace: nil)
    with = _guess_decorator(object_or_enumerable, namespace: namespace) if with.nil?

    if object_or_enumerable.is_a? Enumerable
      object_or_enumerable.map { |object| _decorate(object, with: with, namespace: namespace) }
    else
      with.new(object_or_enumerable, namespace: namespace.to_s)
    end
  end

  def self._guess_decorator(object_or_enumerable, namespace: nil)
    object_or_enumerable = object_or_enumerable.first if object_or_enumerable.is_a? Enumerable
    namespace = "#{namespace}::" if namespace.present?
    decorator = "#{namespace}#{object_or_enumerable.class}Decorator"
    decorator.safe_constantize || raise(Draper::UninferrableDecoratorError.new(object_or_enumerable.class.name, decorator))
  end

  def self.decorable?(object_or_enumerable)
    return false if object_or_enumerable.nil?
    return false if object_or_enumerable.is_a?(Draper::Decorator)
    return false if object_or_enumerable.respond_to?(:empty?) && object_or_enumerable.empty?
    return false if defined?(ActiveRecord::Relation) \
      && object_or_enumerable.is_a?(ActiveRecord::Relation) \
      && object_or_enumerable.blank?

    true
  end
end
