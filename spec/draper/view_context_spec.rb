# frozen_string_literal: true

require "spec_helper"

RSpec.describe Draper::ViewContext do

  describe ".current" do
    it "returns the stored view context from RequestStore" do
      allow(RequestStore).to receive_messages store: { current_view_context: :stored_view_context }

      expect(described_class.current).to be :stored_view_context
    end

    context "when no view context is stored" do
      it "builds a view context" do
        allow(RequestStore).to receive_messages store: {}
        allow(described_class).to receive_messages build_strategy: -> { :new_view_context }

        expect(described_class.current).to be :new_view_context
      end

      it "stores the built view context" do
        store = {}
        allow(RequestStore).to receive_messages store: store
        allow(described_class).to receive_messages build_strategy: -> { :new_view_context }

        described_class.current
        expect(store[:current_view_context]).to be :new_view_context
      end
    end
  end

  describe ".current=" do
    it "stores a helper proxy for the view context in RequestStore" do
      store = {}
      allow(RequestStore).to receive_messages store: store

      described_class.current = :stored_view_context
      expect(store[:current_view_context]).to be :stored_view_context
    end
  end

  describe ".controller" do
    it "returns the stored controller from RequestStore" do
      allow(RequestStore).to receive_messages store: { current_controller: :stored_controller }

      expect(described_class.controller).to be :stored_controller
    end
  end

  describe ".controller=" do
    it "stores a controller in RequestStore" do
      store = {}
      allow(RequestStore).to receive_messages store: store

      described_class.controller = :stored_controller
      expect(store[:current_controller]).to be :stored_controller
    end

    it "cleans context when controller changes" do
      store = {
        current_controller: :stored_controller,
        current_view_context: :stored_view_context
      }

      allow(RequestStore).to receive_messages store: store

      described_class.controller = :other_stored_controller

      expect(store).to include(current_controller: :other_stored_controller)
      expect(store).not_to include(:current_view_context)
    end

    it "doesn't clean context when controller is the same" do
      store = {
        current_controller: :stored_controller,
        current_view_context: :stored_view_context
      }

      allow(RequestStore).to receive_messages store: store

      described_class.controller = :stored_controller

      expect(store).to include(current_controller: :stored_controller)
      expect(store).to include(current_view_context: :stored_view_context)
    end
  end

  describe ".build" do
    it "returns a new view context using the build strategy" do
      allow(described_class).to receive_messages build_strategy: -> { :new_view_context }

      expect(described_class.build).to be :new_view_context
    end
  end

  describe ".build!" do
    it "returns a helper proxy for the new view context" do
      allow(described_class).to receive_messages build_strategy: -> { :new_view_context }

      expect(described_class.build!).to be :new_view_context
    end

    it "stores the helper proxy" do
      store = {}
      allow(RequestStore).to receive_messages store: store
      allow(described_class).to receive_messages build_strategy: -> { :new_view_context }

      described_class.build!
      expect(store[:current_view_context]).to be :new_view_context
    end
  end

  describe ".clear!" do
    it "clears the stored controller and view controller" do
      store = { current_controller: :stored_controller, current_view_context: :stored_view_context }
      allow(RequestStore).to receive_messages store: store

      described_class.clear!
      expect(store).not_to have_key :current_controller
      expect(store).not_to have_key :current_view_context
    end
  end

  describe ".build_strategy" do
    it "defaults to full" do
      expect(described_class.build_strategy).to be_a Draper::ViewContext::BuildStrategy::Full
    end

    it "memoizes" do
      expect(described_class.build_strategy).to be described_class.build_strategy # rubocop:disable RSpec/IdenticalEqualityAssertion
    end
  end
end
