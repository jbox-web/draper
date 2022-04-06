require 'spec_helper'

RSpec.describe Draper do
  describe ".decorate" do
    it "decorates object" do
      object = Product.new
      decorator = described_class.decorate(object)
      expect(decorator.object).to be object
    end
  end
end
