# frozen_string_literal: true

module Draper
  module DecoratorExampleGroup
    extend ActiveSupport::Concern

    included { metadata[:type] = :decorator }
  end

  RSpec.configure do |config|
    config.include DecoratorExampleGroup, file_path: %r{spec/decorators}, type: :decorator

    %i[decorator controller mailer].each do |type|
      config.before(:each, type: type) { Draper::ViewContext.clear! }
    end
  end
end
