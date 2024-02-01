require 'action_view'

module ViewComponent
  module FragmentCaching
    module Resolvers
      class ViewComponentResolver < ActionView::FileSystemResolver
        VIEW_COMPONENT_RUBY_HANDLER = :vc_rb
        public_constant :VIEW_COMPONENT_RUBY_HANDLER

        class PathParser < ActionView::Resolver::PathParser
          class MatchedAttributes
            class << self
              def formats
                @formats ||= (ActionView::Template::Types.symbols | %i(rb)).map(&Regexp.method(:escape)).join('|').freeze
              end

              def handlers
                @handlers ||= ActionView::Template::Handlers.extensions.map(&Regexp.method(:escape)).join('|').freeze
              end

              def locales
                @locales ||= '(?!rb)[a-z]{2}(?:-[A-Z]{2})?'.freeze
              end

              def variants
                @variants ||= '[^.]*'.freeze
              end

              def match_names
                @match_names ||= %i(prefix partial action locale format variant handler).freeze
              end

              def regex
                @regex ||= %r{
                  \A
                  (?:(?<prefix>.*)/)?
                  (?<partial>_)?
                  (?<action>.*?)
                  (?:\.(?<locale>#{locales}))??
                  (?:\.(?<format>#{formats}))??
                  (?:\+(?<variant>#{variants}))??
                  (?:\.(?<handler>#{handlers}))?
                  \z
                }x.freeze
              end
            end

            delegate :[], to: :match

            def initialize(path)
              @match = self.class.regex.match path
            end

            def format
              matched_sym :format
            end

            def handler
              matched_sym(:handler) || (VIEW_COMPONENT_RUBY_HANDLER if format == :rb)
            end

            def locale
              matched_sym :locale
            end

            def variant
              matched_sym :variant
            end

            def method_missing(method_name, *)
              match[method_name] if self.class.match_names.include? method_name
            end

            def respond_to_missing?(method_name)
              self.class.match_names.include? method_name
            end

            private

            attr_reader :match

            def matched_sym(key)
              match[key]&.to_sym
            end
          end
          private_constant :MatchedAttributes

          def parse(path)
            match = MatchedAttributes.new path
            template_path = ActionView::TemplatePath.build match.action, match.prefix || '', !match.partial.nil?
            details = ActionView::TemplateDetails.new match.locale, match.handler, match.format, match.variant
            ParsedPath.new template_path, details
          end
        end
        private_constant :PathParser

        def initialize(path)
          super
          override_path_parser
        end

        def clear_cache
          super
          override_path_parser
        end

        # def find_all(name, prefix = nil, partial = false, details = {}, key = nil, locals = [])
        def find_all(*args)
          name      = args.fetch 0
          prefix    = args.fetch 1, nil
          partial   = false
          details   = args.fetch 3, {}
          given_key = args.fetch 4, nil
          locals    = args.fetch 5, []

          key = build_key given_key, details
          super name, prefix, partial, details, key, locals
        end

        private

        def override_path_parser
          @path_parser = PathParser.new
        end

        def build_key(key, details)
          (key || ActionView::TemplateDetails::Requested.new(**details)).then do |k|
            ActionView::TemplateDetails::Requested.new formats: k.formats | %i(rb),
                                                       handlers: k.handlers,
                                                       locale: k.locale,
                                                       variants: k.variants
          end
        end
      end
    end
  end
end
