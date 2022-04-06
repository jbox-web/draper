# frozen_string_literal: true

module Draper
  class Engine < ::Rails::Engine

    initializer "draper.setup_action_controller" do
      ActiveSupport.on_load :action_controller do
        include Draper::ViewContext::BaseHelper
        include Draper::ViewContext::ControllerHelper
      end
    end

    initializer "draper.setup_action_mailer" do
      ActiveSupport.on_load :action_mailer do
        include Draper::ViewContext::BaseHelper
      end
    end

    config.after_initialize do |_app|
      require "draper/test/rspec_integration" if Rails.env.test? && defined?(RSpec) && RSpec.respond_to?(:configure)
    end

    rake_tasks do
      load "draper/rails/tasks/draper.rake"
    end

  end
end
