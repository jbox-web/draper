# frozen_string_literal: true

module Draper
  module ViewContext
    module ControllerHelper
      extend ActiveSupport::Concern

      included do
        before_action :activate_draper
      end

      # Set the current controller
      def activate_draper
        Draper::ViewContext.controller = self
      end

    end
  end
end
