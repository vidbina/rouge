# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Structurizr < RegexLexer
      title "Structurizr"
      desc "The Structurizr DSL (https://github.com/structurizr/dsl)"
      tag "structurizr"
      filenames "*.dsl"

      state :whitespace do
        rule /\s+/m, Text::Whitespace
      end

      state :comment do
        rule /\/\/.*$/, Comment
        rule /#.*$/, Comment
        rule %r(\/\*.*\*\/$)m, Comment
      end

      state :root do
        mixin :whitespace
        mixin :comment
      end
    end
  end
end
