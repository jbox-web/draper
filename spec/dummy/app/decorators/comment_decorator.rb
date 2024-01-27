# frozen_string_literal: true

class CommentDecorator < Draper::Decorator

  decorates_association :author

  delegate :id, :created_at, :new_record?

  delegate :content

  def commented_date
    if created_at.to_date == DateTime.now.utc.to_date
      "Today"
    else
      "Not Today"
    end
  end

end
