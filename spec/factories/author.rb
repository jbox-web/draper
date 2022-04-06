# frozen_string_literal: true

FactoryBot.define do
  factory :author do |f|
    f.name { Faker::Name.first_name }
  end
end
