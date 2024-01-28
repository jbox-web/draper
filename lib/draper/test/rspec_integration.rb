# frozen_string_literal: true

module Draper
  module Test
    module RspecIntegration
      extend ActiveSupport::Concern

      included { metadata[:type] = :decorator }
    end
  end
end
