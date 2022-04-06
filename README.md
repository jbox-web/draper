# Draper

[![GitHub license](https://img.shields.io/github/license/jbox-web/draper.svg)](https://github.com/jbox-web/draper/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/jbox-web/draper.svg)](https://github.com/jbox-web/draper/releases/latest)
[![CI](https://github.com/jbox-web/draper/workflows/CI/badge.svg)](https://github.com/jbox-web/draper/actions)
[![Code Climate](https://codeclimate.com/github/jbox-web/draper/badges/gpa.svg)](https://codeclimate.com/github/jbox-web/draper)
[![Test Coverage](https://codeclimate.com/github/jbox-web/draper/badges/coverage.svg)](https://codeclimate.com/github/jbox-web/draper/coverage)

Draper adds an object-oriented layer of presentation logic to your Rails
application.

Without Draper, this functionality might have been tangled up in procedural
helpers or adding bulk to your models. With Draper decorators, you can wrap your
models with presentation-related logic to organise - and test - this layer of
your app much more effectively.

## Installation

Put this in your `Gemfile` :

```ruby
git_source(:github){ |repo_name| "https://github.com/#{repo_name}.git" }

gem 'draper', github: 'jbox-web/draper', tag: '1.0.0'
```

then run `bundle install`.

## Writing Decorators

Decorators inherit from `Draper::Decorator`, live in your `app/decorators`
directory, and are named for the model that they decorate:

```ruby
# app/decorators/article_decorator.rb
class ArticleDecorator < Draper::Decorator
# ...
end
```

### Accessing Helpers

Normal Rails helpers are still useful for lots of tasks. Both Rails' provided
helpers and those defined in your app can be accessed within a decorator via the `h` method:

```ruby
class ArticleDecorator < Draper::Decorator
  def emphatic
    h.content_tag(:strong, "Awesome")
  end
end
```

### Accessing the model

When writing decorator methods you'll usually need to access the wrapped model.
While you may choose to use delegation ([covered below](#delegating-methods))
for convenience, you can always use the `object` (or its alias `model`):

```ruby
class ArticleDecorator < Draper::Decorator
  def published_at
    object.published_at.strftime("%A, %B %e")
  end
end
```

### Decorating Associated Objects

You can automatically decorate associated models when the primary model is
decorated. Assuming an `Article` model has an associated `Author` object:

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author
end
```

When `ArticleDecorator` decorates an `Article`, it will also use
`AuthorDecorator` to decorate the associated `Author`.

### Delegating Methods

When your decorator calls `delegate_all`, any method called on the decorator not
defined in the decorator itself will be delegated to the decorated object. This
includes calling `super` from within the decorator. A call to `super` from within
the decorator will first try to call the method on the parent decorator class. If
the method does not exist on the parent decorator class, it will then try to call
the method on the decorated `object`. This is a very permissive interface.

If you want to strictly control which methods are called within views, you can
choose to only delegate certain methods from the decorator to the source model:

```ruby
class ArticleDecorator < Draper::Decorator
  delegate :title, :body
end
```

We omit the `:to` argument here as it defaults to the `object` being decorated.
You could choose to delegate methods to other places like this:

```ruby
class ArticleDecorator < Draper::Decorator
  delegate :title, :body
  delegate :name, :title, to: :author, prefix: true
end
```

From your view template, assuming `@article` is decorated, you could do any of
the following:

```ruby
@article.title # Returns the article's `.title`
@article.body  # Returns the article's `.body`
@article.author_name  # Returns the article's `author.name`
@article.author_title # Returns the article's `author.title`
```
