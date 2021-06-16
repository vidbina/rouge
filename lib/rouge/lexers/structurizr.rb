# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Structurizr < RegexLexer
      title "Structurizr"
      desc "The Structurizr DSL (https://github.com/structurizr/dsl)"
      tag "structurizr"
      filenames "*.dsl", "*.structurizr"

      def self.identifier
        %r([a-zA-Z0-9\-_\.]+)
      end

      identifier = self.identifier

      state :identifier do
        mixin :whitespace
        rule %r/#{identifier}\b/, Name::Variable
      end

      state :whitespace do
        rule %r/\s+/m, Text::Whitespace
      end

      state :comment do
        rule %r/\/\/.*$/, Comment
        rule %r/#.*$/, Comment
        rule %r(\/\*.*?\*\/$)m, Comment::Multiline
      end

      state :constant do
        mixin :whitespace
        rule %r/!constant\b/, Keyword::Declaration, :constant_name
      end

      state :constant_name do
        mixin :whitespace
        rule %r/[a-zA-Z0-9\-_\.]+\b/, Name::Constant, :constant_value
      end

      state :constant_value do
        mixin :whitespace
        rule %r/".*"/ do
          token Literal::String
          pop! 2
        end
      end

      state :root do
        mixin :whitespace
        mixin :comment

        mixin :constant
      end
    end
  end
end
