# frozen_string_literal: true

FactoryBot.define do
  factory :comment do |f|
    f.content { Faker::Lorem.paragraph }
    f.association :author
    f.association :post
  end
end
