# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Structurizr < RegexLexer
      title "Structurizr"
      desc "The Structurizr DSL (https://github.com/structurizr/dsl)"
      tag "structurizr"
      filenames "*.c4", "*.dsl", "*.structurizr"

      # TODO: Handle https://github.com/structurizr/dsl/blob/master/docs/language-reference.md#relationship
      # TODO: Verify all examples parse from https://github.com/structurizr/dsl/tree/master/examples

      def self.keywords
        @keywords ||= Set.new %w(workspace model enterprise group person
        softwareSystem container component deploymentEnvironment
        deploymentGroup deploymentNode infrastructureNode
        softwareSystemInstance containerInstance healthCheck element tags url
        properties perspectives views systemLandscape systemContext container
        component filtered dynamic deployment custom include exclude autoLayout
        animation title styles theme themes branding terminology configuration
        users)
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

      state :include do
        mixin :whitespace
        rule %r/(#{keywords_include.join('|')}\b)(\p{Blank}+)([^\n]+)/i do
          groups Keyword, Text::Whitespace, Text
        end
      end

      state :doc_include do
        mixin :whitespace
        rule %r/(#{keywords_doc_include.join('|')}\b)(\p{Blank}+)([^\n]+)/i do
          groups Comment, Text::Whitespace, Text
        end
      end

      state :constant do
        mixin :whitespace
        rule %r/(!constant\b)(\p{Blank}+)(#{identifier}\b)(\p{Blank}+)/i do
          groups Keyword::Declaration, Text::Whitespace, Name::Constant, Text::Whitespace
          push :constant_value
        end
      end

      state :constant_value do
        mixin :string
        rule %r/\n/, Text::Whitespace, :pop!
      end

      state :string do
        rule %r/"/, Str::Double, :string_body
      end

      state :string_body do
        rule %r/[$][{]/, Str::Interpol, :string_intp
        rule %r/"/, Str::Double, :pop!
        rule %r/./, Str
      end

      state :string_intp do
        rule %r/}/, Str::Interpol, :pop!
        mixin :expr
      end

      state :construct do
        rule %r/(#{keywords.join('|')}\b)/i, Keyword, :construct_args
      end

      state :construct_args do
        rule %r/\n/, Text::Whitespace, :pop!

        mixin :whitespace
        mixin :string
        mixin :identifier

        rule %r/{/, Punctuation, :construct_body
      end

      state :construct_body do
        mixin :whitespace
        mixin :expr
        mixin :construct

        rule %r/}/ do
          token Punctuation
          pop! 2
        end
      end

      state :expr_left do
        rule %r/(#{identifier}\b)(\p{Blank}*)(#{operators.join('|')})/i do
          groups Keyword::Declaration, Text::Whitespace, Operator
        end
      end

      state :expr do
        mixin :whitespace
        mixin :expr_left
      end

      state :root do
        mixin :whitespace
        mixin :comment

        mixin :constant
        mixin :include
        mixin :doc_include

        mixin :construct
      end
    end
  end
end
