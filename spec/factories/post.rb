# frozen_string_literal: true

FactoryBot.define do
  factory :post do |f|
    f.title   { Faker::Lorem.sentence }
    f.content { Faker::Lorem.paragraph }
    f.association :author
  end
end
