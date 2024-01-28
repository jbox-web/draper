# frozen_string_literal: true

module Email
  class CommentDecorator < CommentDecorator
    # reset namespace to '' to not inherit 'Email' module namespace
    decorates_association :author, with: ::Bar::FooDecorator, namespace: ''
  end
end
