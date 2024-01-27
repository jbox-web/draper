# frozen_string_literal: true

class UserDecorator < Draper::Decorator
  def to_s
    object.name
  end
end
