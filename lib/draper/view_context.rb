# frozen_string_literal: true

require "draper/view_context/build_strategy"
require "draper/view_context/base_helper"
require "draper/view_context/controller_helper"

module Draper
  module ViewContext
    module_function

    # Sets the current view context.
    def current=(view_context)
      RequestStore.store[:current_view_context] = view_context
    end

    # Returns the current view context
    def current
      RequestStore.store.fetch(:current_view_context) { build! }
    end

    # Builds a new view context and sets it as the current view context.
    def build!
      # send because we want to return the ViewContext returned from #current=
      send :current=, build
    end

    # Builds a new view context for usage in tests. See {test_strategy} for
    # details of how the view context is built.
    def build
      build_strategy.call
    end

    def build_strategy
      @build_strategy ||= Draper::ViewContext::BuildStrategy.new(:full)
    end

    # Returns the current controller.
    def controller
      RequestStore.store[:current_controller]
    end

    # Sets the current controller. Clears view context when we are setting
    # different controller.
    def controller=(controller)
      clear! if RequestStore.store[:current_controller] != controller
      RequestStore.store[:current_controller] = controller
    end

    # Clears the saved controller and view context.
    def clear!
      RequestStore.store.delete :current_controller
      RequestStore.store.delete :current_view_context
    end

  end
end
