require 'spec_helper'

RSpec.describe Draper::Decorator do

  describe ".helpers" do
    it "returns the current view context" do
      allow(Draper::ViewContext).to receive_messages current: :current_view_context
      expect(described_class.helpers).to be :current_view_context
    end

    it "is aliased to .h" do
      allow(Draper::ViewContext).to receive(:current).and_return(:current_view_context)
      expect(described_class.h).to be :current_view_context
    end
  end

  describe "#helpers" do
    it "returns the current view context" do
      allow(Draper::ViewContext).to receive_messages current: :current_view_context
      subject = described_class.new(Model.new)
      expect(subject.helpers).to be :current_view_context
    end

    it "is aliased to #h" do
      allow(Draper::ViewContext).to receive_messages current: :current_view_context
      subject = described_class.new(Model.new)
      expect(subject.h).to be :current_view_context
    end
  end

  describe "#object" do
    it "returns the wrapped object" do
      object = Model.new
      decorator = described_class.new(object)

      expect(decorator.object).to be object
    end

    it "is aliased to #model" do
      object = Model.new
      decorator = described_class.new(object)

      expect(decorator.model).to be object
    end
  end

  describe "#to_model" do
    it "returns the decorator" do
      decorator = described_class.new(Model.new)

      expect(decorator.to_model).to be decorator
    end
  end

  describe "#to_param" do
    it "delegates to the object" do
      decorator = described_class.new(double(to_param: :delegated))

      expect(decorator.to_param).to be :delegated
    end
  end

  describe "#present?" do
    it "delegates to the object" do
      decorator = described_class.new(double(present?: :delegated))

      expect(decorator.present?).to be :delegated
    end
  end

  describe "#blank?" do
    it "delegates to the object" do
      decorator = described_class.new(double(blank?: :delegated))

      expect(decorator.blank?).to be :delegated
    end
  end

  describe "#to_partial_path" do
    it "delegates to the object" do
      decorator = described_class.new(double(to_partial_path: :delegated))

      expect(decorator.to_partial_path).to be :delegated
    end
  end

  describe "#to_s" do
    it "delegates to the object" do
      decorator = described_class.new(double(to_s: :delegated))

      expect(decorator.to_s).to be :delegated
    end
  end

  describe "#inspect" do
    it "returns a detailed description of the decorator" do
      decorator = ProductDecorator.new(double)

      expect(decorator.inspect).to match(/#<ProductDecorator:0x\h+ .+>/)
    end

    it "includes the object" do
      decorator = described_class.new(double(inspect: "#<the object>"))

      expect(decorator.inspect).to include "@object=#<the object>"
    end

    it "includes other instance variables" do
      decorator = described_class.new(double)
      decorator.instance_variable_set :@foo, "bar"

      expect(decorator.inspect).to include '@foo="bar"'
    end
  end

  describe "#attributes" do
    it "returns only the object's attributes that are implemented by the decorator" do
      decorator = described_class.new(double(attributes: {foo: "bar", baz: "qux"}))
      allow(decorator).to receive(:foo)

      expect(decorator.attributes).to eq({foo: "bar"})
    end
  end
end
