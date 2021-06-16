# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Structurizr < RegexLexer
      title "Structurizr"
      desc "The Structurizr DSL (https://github.com/structurizr/dsl)"
      tag "structurizr"
      filenames "*.c4", "*.dsl", "*.structurizr"

      # TODO: Verify all examples parse from https://github.com/structurizr/dsl/tree/master/examples

      def self.keywords
        @keywords ||= Set.new %w(workspace model enterprise group person
        softwareSystem container component deploymentEnvironment
        deploymentGroup deploymentNode infrastructureNode
        softwareSystemInstance containerInstance healthCheck element tags url
        properties perspectives views systemLandscape systemContext container
        component filtered dynamic deployment custom include exclude autoLayout
        animation title styles element relationship theme themes branding
        terminology configuration users)
      end

      def self.keywords_include
        @keywords_include ||= Set.new %w(!include)
      end

      def self.keywords_doc_include
        @keywords_doc_include ||= Set.new %w(!docs !adrs)
      end

      keywords = self.keywords
      keywords_include = self.keywords_include
      keywords_doc_include = self.keywords_doc_include

      def self.operators
        @operators ||= Set.new %w(-> == != =-> = )
      end

      operators = self.operators

      def self.identifier
        %r([a-zA-Z0-9\-_\.]+)
      end

      identifier = self.identifier

      state :identifier do
        mixin :whitespace
        rule %r/(#{identifier})\b/, Name::Variable
      end

      state :whitespace do
        rule %r/\s+/m, Text::Whitespace
      end

      state :comment do
        rule %r/\/\/.*$/, Comment
        rule %r/#.*$/, Comment
        rule %r(\/\*.*?\*\/$)m, Comment::Multiline
      end

      state :include do
        mixin :whitespace
        rule %r/(#{keywords_include.join('|')})\b(\p{Blank}+)([^\n]+)/i do
          groups Keyword, Text::Whitespace, Text
        end
        rule %r/(#{keywords_doc_include.join('|')})\b(\p{Blank}+)([^\n]+)/i do
          groups Comment, Text::Whitespace, Text
        end
      end

      state :constant_def do
        mixin :whitespace
        rule %r/(!constant)\b(\p{Blank}+)(#{identifier})\b(\p{Blank}+)/i do
          groups Keyword::Declaration, Text::Whitespace, Name::Constant, Text::Whitespace
          push :value
        end
      end

      state :value do
        rule %r/\n/, Text::Whitespace, :pop!
        mixin :whitespace
        mixin :string
        rule %r/\*/, Str::Symbol
        rule %r/\b(?:true|false)\b/, Keyword::Constant, :pop!
        # TODO: Use identifier mixin and explore refactoring for statelessness
        rule %r/(#{identifier})\b/, Name::Variable, :pop!
        rule %r/#([a-fA-F0-9]{3,8})\b/, Str::Symbol, :pop!
        rule %r/-?(?:0|[1-9]\d*)\.\d+(?:e[+-]?\d+)?/i, Num::Float, :pop!
        rule %r/-?(?:0|[1-9]\d*)(?:e[+-]?\d+)?/i, Num::Integer, :pop!
      end

      state :string do
        rule %r/https?:[^\p{Blank}]*/, Str::Other
        rule %r/"/ do
          token Str::Double
          pop!
          push :string_body
        end
      end

      state :string_body do
        rule %r/[$][{]/, Str::Interpol, :string_intp
        rule %r/"/, Str::Double, :pop!
        rule %r/./, Str
      end

      state :string_intp do
        rule %r/}/, Str::Interpol, :pop!
        rule %r/(#{identifier})\b/, Name::Variable, :pop!
      end

      state :property do
        rule %r/(#{identifier})\b(\p{Blank}*)/i do
          groups Keyword::Declaration, Text::Whitespace
          push :value
        end
      end

      state :construct do
        rule %r/\b(#{keywords.join('|')})\b/i, Keyword::Type, :construct_args
      end

      state :construct_args do
        rule %r/\n/, Text::Whitespace, :pop!
        rule %r/\*/, Str::Symbol

        mixin :whitespace
        mixin :string
        mixin :identifier

        rule %r/{/ do
          token Punctuation
          pop!
          push :construct_body
        end
      end

      state :construct_body do
        mixin :whitespace
        mixin :comment

        mixin :constant_def
        mixin :include

        mixin :expr
        mixin :construct
        mixin :property

        rule %r/}/, Punctuation, :pop!
        rule %r/{/, Punctuation, :construct_body
      end

      state :expr do
        mixin :whitespace

        rule %r/(#{identifier})\b(\p{Blank}*)(#{operators.join('|')})/i do
          groups Keyword::Declaration, Text::Whitespace, Operator
        end

        rule %r/->/, Operator
      end

      state :root do
        mixin :whitespace
        mixin :comment

        mixin :constant_def
        mixin :include

        mixin :expr
        mixin :construct
      end
    end
  end
end
