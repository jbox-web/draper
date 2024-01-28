# frozen_string_literal: true

require "active_support/concern"
require "request_store"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/draper/rails")
loader.ignore("#{__dir__}/draper/test")
loader.setup

module Draper
  require "draper/engine" if defined?(Rails)

  class UninferrableDecoratorError < NameError
    def initialize(klass, decorator)
      super("Could not infer a decorator for #{klass}. Looked for #{decorator}.")
    end
  end

  class << self

    def default_controller
      @default_controller ||= ApplicationController
    end

    def default_controller=(controller)
      @default_controller = controller
    end

    def decorate(object_or_enumerable, with: nil, namespace: nil)
      return object_or_enumerable unless decorable?(object_or_enumerable)

      object_or_enumerable = _decorate(object_or_enumerable, with: with, namespace: namespace)

      block_given? ? yield(object_or_enumerable) : object_or_enumerable
    end

    def _decorate(object_or_enumerable, with: nil, namespace: nil)
      klass = _guess_decorator(object_or_enumerable, with: with, namespace: namespace)

      if object_or_enumerable.is_a? Enumerable
        object_or_enumerable.map { |object| klass.new(object, namespace: namespace.to_s) }
      else
        klass.new(object_or_enumerable, namespace: namespace.to_s)
      end
    end

    def _guess_decorator(object_or_enumerable, with: nil, namespace: nil)
      object_or_enumerable = object_or_enumerable.first if object_or_enumerable.is_a? Enumerable
      klass     = with || "#{object_or_enumerable.class.name}Decorator"
      decorator = [namespace, klass].compact.join("::")
      decorator.safe_constantize || raise(Draper::UninferrableDecoratorError.new(klass, decorator))
    end

    def decorable?(object_or_enumerable)
      return false if defined?(ActiveRecord::Relation) \
        && object_or_enumerable.is_a?(ActiveRecord::Relation) \
        && object_or_enumerable.blank?

      return false if object_or_enumerable.respond_to?(:empty?) && object_or_enumerable.empty?
      return false if object_or_enumerable.nil?
      return false if object_or_enumerable.is_a?(Draper::Decorator)

      true
    end

  end
end
