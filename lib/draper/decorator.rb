# frozen_string_literal: true

module Draper
  class Decorator

    class << self

      # @overload delegate(*methods, options = {})
      #   Overrides {http://api.rubyonrails.org/classes/Module.html#method-i-delegate Module.delegate}
      #   to make `:object` the default delegation target.
      #
      #   @return [void]
      def delegate(*methods)
        options = methods.extract_options!
        super(*methods, **options.reverse_merge(to: :object))
      end

      # Define that an association must be decorated.
      #
      # @param relation_name [String, Symbol] the association name to decorate.
      # @param with [Class] the decorator class to use. If empty a decorator will be guessed.
      #
      # @example Define an association to decorate
      #   class UserDecorator < Dekorator::Base
      #     decorates_association :posts
      #   end
      #
      #   # A decorator could be precise
      #   class UserDecorator < Dekorator::Base
      #     decorates_association :posts, PostDecorator
      #   end
      def decorates_association(relation_name, with: nil, namespace: nil, scope: nil)
        relation_sym = ":#{relation_name}"
        with         = with.nil? ? "nil" : "'#{with}'"
        namespace    = namespace.nil? ? "nil" : "'#{namespace}'"
        scope        = scope.nil? ? "nil" : ":#{scope}"

        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          # frozen_string_literal: true
          def #{relation_name}
            @decorated_associations[#{relation_sym}] ||= decorate(_scoped_decorator(#{relation_sym}, #{scope}), with: #{with}, namespace: #{namespace})
          end
        METHOD
      end

      # Access the helpers proxy to call built-in and user-defined
      # Rails helpers from a class context.
      #
      # @return [HelperProxy] the helpers proxy
      def helpers
        Draper::ViewContext.current
      end
      alias h helpers

    end

    # @return the object being decorated.
    attr_reader :object
    alias model object

    def initialize(object, namespace: nil)
      @object    = object
      @namespace = namespace
      @decorated_associations = {}
    end

    # ActiveModel compatibility
    delegate :to_param, :to_partial_path, :to_s

    # In case object is nil
    delegate :present?, :blank?

    # Access the helpers proxy to call built-in and user-defined
    # Rails helpers. Aliased to `h` for convenience.
    delegate :helpers, to: :class
    alias h helpers

    # ActiveModel compatibility
    def to_model
      self
    end

    # @return [Hash] the object's attributes, sliced to only include those
    # implemented by the decorator.
    def attributes
      object.attributes.select { |attribute, _| respond_to?(attribute) }
    end

    # Compares the source object with a possibly-decorated object.
    #
    # @return [Boolean]
    def ==(other)
      super || self.class == other.class && object == other.object
    end

    # Delegates equality to :== as expected
    #
    # @return [Boolean]
    def eql?(other)
      self == other
    end

    # Returns a unique hash for a decorated object based on
    # the decorator class and the object being decorated.
    #
    # @return [Fixnum]
    def hash
      [self.class, object].hash
    end

    private

      def decorate(object, with: nil, namespace: nil)
        Draper.decorate(object, with: with, namespace: namespace || @namespace)
      end

      def _scoped_decorator(relation_name, scope)
        result = object.public_send(relation_name)
        scope ? result.public_send(scope) : result
      end

  end
end
