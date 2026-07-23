# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Draper do
  describe '.decorate' do
    context 'when decorator exists' do
      it 'decorates object' do
        object = Product.new
        decorator = described_class.decorate(object)
        expect(decorator.object).to be object
      end
    end

    context "when decorator doesn't exist" do
      it 'decorates object' do
        object = Model.new
        expect {
          described_class.decorate(object)
        }.to raise_error(Draper::UninferrableDecoratorError)
      end
    end

    context 'when a block is given' do
      it 'yields the decorated object and returns the block result' do
        object  = Product.new
        yielded = nil

        result = described_class.decorate(object) do |decorator|
          yielded = decorator
          :block_result
        end

        expect(yielded).to be_a ProductDecorator
        expect(yielded.object).to be object
        expect(result).to eq :block_result
      end
    end
  end

  describe '.decorable?' do
    it 'returns false for nil' do
      expect(described_class.decorable?(nil)).to be false
    end

    it 'returns false for an empty enumerable' do
      expect(described_class.decorable?([])).to be false
    end

    it 'returns true for a non-empty enumerable' do
      expect(described_class.decorable?([Product.new])).to be true
    end

    it 'returns false for an already-decorated object' do
      expect(described_class.decorable?(ProductDecorator.new(Product.new))).to be false
    end

    it 'returns true for a plain object' do
      expect(described_class.decorable?(Product.new)).to be true
    end

    it 'returns false for a blank ActiveRecord::Relation' do
      expect(described_class.decorable?(Post.none)).to be false
    end

    it 'returns true for a present ActiveRecord::Relation' do
      FactoryBot.create(:post)
      expect(described_class.decorable?(Post.all)).to be true
    end
  end
end
