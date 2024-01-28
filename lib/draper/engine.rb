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
      if Rails.env.test? && defined?(RSpec) && RSpec.respond_to?(:configure)
        require "draper/test/rspec_integration"

        RSpec.configure do |config|
          config.include Draper::Test::RspecIntegration, file_path: %r{spec/decorators}, type: :decorator

          %i[decorator controller mailer].each do |type|
            config.before(:each, type: type) { Draper::ViewContext.clear! }
          end
        end
      end
    end

    rake_tasks do
      load "draper/rails/tasks/draper.rake"
    end

  end
end
