require 'view_component'

module ViewComponent
  module FragmentCaching
    class Configuration
      attr_reader :view_component_paths

      def initialize
        self.view_component_path =
          if ViewComponent::Base.respond_to? :view_component_path
            ::ViewComponent::Base.view_component_path
          else
            ViewComponent::FragmentCaching::Engine.config.view_component.generate.path
          end
      end

      def view_component_paths=(path_or_paths)
        @view_component_paths = Array(path_or_paths)
      end
      alias view_component_path= view_component_paths=
    end
  end
end
