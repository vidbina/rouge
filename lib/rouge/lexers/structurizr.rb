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
        rule %r/(!constant\b)(\s+)(#{identifier}\b)(\s+)/ do
          groups Keyword::Declaration, Text::Whitespace, Name::Constant, Text::Whitespace
          push :constant_value
        end
      end

      state :constant_value do
        rule %r/"/, Str::Double, :string
        rule %r/\n/, Text::Whitespace, :pop!
      end

      state :string do
        rule %r/[$][{]/, Str::Interpol, :string_intp
        rule %r/"/, Str::Double, :pop!
        rule %r/./, Str
      end

      state :string_intp do
        rule %r/}/, Str::Interpol, :pop!
        mixin :expr_start
      end

      state :expr_start do
        mixin :whitespace
        mixin :identifier
      end

      state :root do
        mixin :whitespace
        mixin :comment

        mixin :constant
      end
    end
  end
end
