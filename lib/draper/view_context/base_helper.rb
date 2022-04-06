# frozen_string_literal: true

module Draper
  module ViewContext
    module BaseHelper
      extend ActiveSupport::Concern

      included do
        helper_method :decorate
      end

      # Hooks into a controller or mailer to save the view context in {current}.
      def view_context
        super.tap do |context|
          Draper::ViewContext.current = context
        end
      end

      def decorate(object_or_enumerable, with: nil, namespace: nil)
        Draper.decorate(object_or_enumerable, with: with, namespace: namespace)
      end

    end
  end
end
