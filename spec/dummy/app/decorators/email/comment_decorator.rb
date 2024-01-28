# frozen_string_literal: true

module Email
  class CommentDecorator < CommentDecorator
    decorates_association :author, with: 'Foo', namespace: '::Bar'
  end
end
