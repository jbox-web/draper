# frozen_string_literal: true

class AuthorDecorator < Draper::Decorator
  def to_s
    object.name
  end
end
