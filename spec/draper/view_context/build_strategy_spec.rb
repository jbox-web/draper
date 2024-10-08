# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ViewContext' do
  def fake_view_context
    double('ViewContext')
  end

  def fake_controller(view_context = fake_view_context)
    double('Controller', view_context: view_context, request: double('Request'))
  end

  describe Draper::ViewContext::BuildStrategy::Full do
    describe '#call' do
      context 'when a current controller is set' do
        it "returns the controller's view context" do
          view_context = fake_view_context
          allow(Draper::ViewContext).to receive_messages controller: fake_controller(view_context)
          strategy = described_class.new

          expect(strategy.call).to be view_context
        end
      end

      context 'when a current controller is not set' do
        it 'uses ApplicationController' do
          expect(Draper::ViewContext.controller).to be_nil
          view_context = described_class.new.call
          expect(view_context.controller).to eq Draper::ViewContext.controller
          expect(view_context.controller).to be_an ApplicationController
        end
      end

      it 'adds a request if one is not defined' do
        controller = Class.new(ActionController::Base).new
        allow(Draper::ViewContext).to receive_messages controller: controller
        strategy = described_class.new

        expect(controller.request).to be_nil
        strategy.call
        expect(controller.request).to be_an ActionController::TestRequest
        expect(controller.params).to be_empty

        # sanity checks
        expect(controller.view_context.request).to be controller.request
        expect(controller.view_context.params).to be controller.params
      end

      it 'compatible with rails 5.1 change on ActionController::TestRequest.create method' do
        ActionController::TestRequest.class_eval do
          if ActionController::TestRequest.method(:create).parameters.first == []
            def create(_controller_class)
              create
            end
          end
        end
        controller = Class.new(ActionController::Base).new
        allow(Draper::ViewContext).to receive_messages controller: controller
        strategy = described_class.new

        expect(controller.request).to be_nil
        strategy.call
        expect(controller.request).to be_an ActionController::TestRequest
      end

      it 'adds methods to the view context from the constructor block' do
        allow(Draper::ViewContext).to receive(:controller).and_return(fake_controller)
        strategy = described_class.new do
          def a_helper_method; end
        end

        expect(strategy.call).to respond_to :a_helper_method
      end

      it 'includes modules into the view context from the constructor block' do
        view_context = Object.new
        allow(Draper::ViewContext).to receive(:controller).and_return(fake_controller(view_context))
        helpers = Module.new do
          def a_helper_method; end
        end
        strategy = described_class.new do
          include helpers
        end

        expect(strategy.call).to respond_to :a_helper_method
      end
    end
  end

  describe Draper::ViewContext::BuildStrategy::Fast do
    describe '#call' do
      it 'returns an instance of a subclass of ActionView::Base' do
        strategy = described_class.new

        returned = strategy.call

        expect(returned).to be_an ActionView::Base
        expect(returned.class).not_to be ActionView::Base
      end

      it 'returns different instances each time' do
        strategy = described_class.new

        expect(strategy.call).not_to be strategy.call
      end

      it 'returns the same subclass each time' do
        strategy = described_class.new

        expect(strategy.call.class).to be strategy.call.class # rubocop:disable RSpec/IdenticalEqualityAssertion
      end

      it 'adds methods to the view context from the constructor block' do
        strategy = described_class.new do
          def a_helper_method; end
        end

        expect(strategy.call).to respond_to :a_helper_method
      end

      it 'includes modules into the view context from the constructor block' do
        helpers = Module.new do
          def a_helper_method; end
        end
        strategy = described_class.new do
          include helpers
        end

        expect(strategy.call).to respond_to :a_helper_method
      end
    end
  end
end
