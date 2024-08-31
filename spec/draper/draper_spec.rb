# frozen_string_literal: true

require "spec_helper"

RSpec.describe Draper do
  describe ".decorate" do
    context "when decorator exists" do
      it "decorates object" do
        object = Product.new
        decorator = described_class.decorate(object)
        expect(decorator.object).to be object
      end
    end

    context "when decorator doesn't exist" do
      it "decorates object" do
        object = Model.new
        expect {
          described_class.decorate(object)
        }.to raise_error(Draper::UninferrableDecoratorError)
      end
    end
  end
end
