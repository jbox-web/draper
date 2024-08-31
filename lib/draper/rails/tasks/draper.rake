# frozen_string_literal: true

task stats: "draper:statsetup" # rubocop:disable Rake/Desc

namespace :draper do
  task statsetup: :environment do # rubocop:disable Rake/Desc
    require "rails/code_statistics"

    ::STATS_DIRECTORIES << ["Decorators", "app/decorators"] # rubocop:disable Style/RedundantConstantBase
  end
end
