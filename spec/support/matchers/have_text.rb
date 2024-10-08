# frozen_string_literal: true

module HaveTextMatcher
  def have_text(text)
    HaveText.new(text)
  end

  class HaveText
    def initialize(text)
      @text = text
    end

    def in(css)
      @css = css
      self
    end

    def matches?(subject)
      @subject = subject

      @subject.has_css?(@css || '*', text: @text)
    end

    def failure_message
      "expected to find #{@text.inspect} #{within}"
    end

    def failure_message_when_negated
      "expected not to find #{@text.inspect} #{within}"
    end

    private

      def within
        if @css && @subject.has_css?(@css)
          "within\n#{@subject.find(@css).native}"
        else
          inside
        end
      end

      def inside
        @css ? "inside #{@css.inspect}" : 'anywhere'
      end

  end
end
