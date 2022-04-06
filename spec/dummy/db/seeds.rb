FactoryBot.definition_file_paths = [File.join(File.expand_path('../../..', __dir__), 'spec/factories')]

FactoryBot.find_definitions
3.times { FactoryBot.create(:comment) }
