module ViewComponent
  module FragmentCaching
    module Trackers
      module ViewComponentTracking
        EXPLICIT_VIEW_COMPONENT_DEPENDENCY = /# View Component Dependency: (\S+)/.freeze
        private_constant :EXPLICIT_VIEW_COMPONENT_DEPENDENCY

        CAMEL_PHRASE = /(?:([A-Z]+[a-z]*[0-9]*)+)/.freeze
        private_constant :CAMEL_PHRASE

        MODULE_NAME = /(?:((::)?#{CAMEL_PHRASE}+)+)/.freeze
        private_constant :MODULE_NAME

        VIEW_COMPONENT_NAME = /(?:#{MODULE_NAME}Component)/.freeze
        private_constant :VIEW_COMPONENT_NAME

        MODULE_NAME_END = /(?:\b[^:])/.freeze
        private_constant :MODULE_NAME_END

        INVOKE_METHOD = /(?:\s*\.\s*(((public_)?send?(\s*\(?\s*):)?))/.freeze
        private_constant :INVOKE_METHOD

        INITIALIZE_METHOD_NAME = /(?:\b(new|with_collection)\b)/.freeze
        private_constant :INITIALIZE_METHOD_NAME

        VIEW_COMPONENT_RENDER_ARGUMENTS = /
          \A
          (?:\s*\(?\s*)
          (?<view_component>#{VIEW_COMPONENT_NAME})
          (?:#{INVOKE_METHOD})
          (?:#{INITIALIZE_METHOD_NAME})
        /xm.freeze
        private_constant :VIEW_COMPONENT_RENDER_ARGUMENTS

        CLASS_INHERITANCE = /(?:\s*\bclass\s+#{MODULE_NAME}\s*<\s*)/.freeze
        private_constant :CLASS_INHERITANCE

        VIEW_COMPONENT_INHERITANCE_DEPENDENCY = /
          (?:#{CLASS_INHERITANCE})
          (?<view_component>#{VIEW_COMPONENT_NAME})
          (?:#{MODULE_NAME_END})
        /xm.freeze
        private_constant :VIEW_COMPONENT_INHERITANCE_DEPENDENCY

        def dependencies
          render_dependencies |
            explicit_dependencies |
            view_component_inheritance_dependencies |
            explicit_view_component_dependencies
        end

        private

        def render_dependencies
          [].tap do |render_dependencies|
            render_calls = source.split(/\brender\b/).drop(1)

            render_calls.each do |arguments|
              add_dependencies render_dependencies, arguments, self.class::LAYOUT_DEPENDENCY
              add_dependencies render_dependencies, arguments, self.class::RENDER_ARGUMENTS
              add_dependencies render_dependencies, arguments, VIEW_COMPONENT_RENDER_ARGUMENTS
            end
          end
        end

        def add_dependencies(render_dependencies, arguments, pattern)
          arguments.scan pattern do
            match = Regexp.last_match.named_captures.symbolize_keys
            add_dynamic_dependency render_dependencies, match[:dynamic]
            add_static_dependency render_dependencies, match[:static], match[:quote]
            add_view_component_dependency render_dependencies, match[:view_component]
          end
        end

        def add_view_component_dependency(dependencies, dependency)
          return if dependency.blank?

          path = dependency.underscore
          dependencies << path unless dependencies.include? path
        end

        def view_component_inheritance_dependencies
          scan_source VIEW_COMPONENT_INHERITANCE_DEPENDENCY
        end

        def explicit_view_component_dependencies
          scan_source EXPLICIT_VIEW_COMPONENT_DEPENDENCY
        end

        def scan_source(pattern)
          source.scan(pattern).flatten.uniq.map(&:underscore)
        end
      end
    end
  end
end
