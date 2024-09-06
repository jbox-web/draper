# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Draper', js: true do
  spec_types = {
    view: ['/decorated_posts/1', 'DecoratorController'],
    mailer: ['/decorated_posts/1/mail', 'PostMailer']
  }

  # Environment:
  #     development
  # Draper view context controller:
  #     PostsController
  # Posted:
  #     Today
  # Built-in helpers:
  #     Once upon a...
  # Built-in private helpers:
  #     <script>danger</script>
  # Helpers from app/helpers:
  #     Hello, world!
  # Helpers from the controller:
  #     Goodnight, moon!
  # Path with decorator:
  #     http://www.example.com:12345/en/decorated_posts/1
  # Path with model:
  #     /en/decorated_posts/1
  # Path with id:
  #     /en/decorated_posts/1
  # URL with decorator:
  #     http://www.example.com:12345/en/decorated_posts/1
  # URL with model:
  #     http://www.example.com:12345/en/decorated_posts/1
  # URL with id:
  #     http://www.example.com:12345/en/decorated_posts/1

  spec_types.each do |type, (path, controller)|
    describe "in a #{type}" do
      before do
        FactoryBot.create(:comment, content: 'foo')
        visit path
      end

      it 'runs in the correct environment' do
        expect(page).to have_text(Rails.env).in('#environment')
      end

      it 'uses the correct view context controller' do
        expect(page).to have_text(controller).in('#controller')
      end

      it 'can use built-in helpers' do
        expect(page).to have_text('Once upon a...').in('#truncated')
      end

      it 'can use built-in private helpers' do
        # Nokogiri unescapes text!
        expect(page).to have_text('<script>danger</script>').in('#html_escaped')
      end

      it 'can use user-defined helpers from app/helpers' do
        expect(page).to have_text('Hello, world!').in('#hello_world')
      end

      it 'can use user-defined helpers from the controller A' do
        expect(page).to have_text('Goodnight, moon!').in('#goodnight_moon')
      end

      it 'can use user-defined helpers from the controller B' do
        expect(page).to have_text('foo').in('#comments_content')
      end

      it 'can use user-defined helpers from the controller C' do
        expect(page).to have_text('Today').in('#comments_date')
      end

      # _path helpers aren't available in mailers
      if type == :view
        it 'can be passed to path helpers' do
          expect(page).to have_text('/en/decorated_posts/1').in('#path_with_decorator')
        end

        it 'can use path helpers with a model' do
          expect(page).to have_text('/en/decorated_posts/1').in('#path_with_model')
        end

        it 'can use path helpers with an id' do
          expect(page).to have_text('/en/decorated_posts/1').in('#path_with_id')
        end
      end

      it 'can be passed to url helpers' do
        expect(page).to have_text('http://www.example.com:12345/en/decorated_posts/1').in('#url_with_decorator')
      end

      it 'can use url helpers with a model' do
        expect(page).to have_text('http://www.example.com:12345/en/decorated_posts/1').in('#url_with_model')
      end

      it 'can use url helpers with an id' do
        expect(page).to have_text('http://www.example.com:12345/en/decorated_posts/1').in('#url_with_id')
      end

    end
  end
end
