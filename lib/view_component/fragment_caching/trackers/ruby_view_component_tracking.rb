module ViewComponent
  module FragmentCaching
    module Trackers
      module RubyViewComponentTracking
        def dependencies
          super |
            view_component_inheritance_dependencies |
            explicit_view_component_dependencies
        end

        private

        def render_dependencies
          base_render_deps = super

          vc_render_deps = []
          render_calls = template.source.split(/\brender\b/).drop(1)
          render_calls.each do |arguments|
            add_view_component_dependency vc_render_deps, arguments
          end

          base_render_deps | vc_render_deps
        end

        def add_view_component_dependency(dependencies, arguments)
          arguments.scan VIEW_COMPONENT_RENDER_ARGUMENTS do
            match = Regexp.last_match.named_captures.symbolize_keys
            component_name = match[:view_component]
            next if component_name.blank?

            path = component_name.underscore
            dependencies << path if dependencies.exclude? path
          end
        end

        def view_component_inheritance_dependencies
          scan_source VIEW_COMPONENT_INHERITANCE_DEPENDENCY
        end

        def explicit_view_component_dependencies
          scan_source EXPLICIT_VIEW_COMPONENT_DEPENDENCY
        end

        def scan_source(pattern)
          template.source.scan(pattern).flatten.uniq.map(&:underscore)
        end
      end
    end
  end
end
