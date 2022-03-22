require 'view_component/fragment_caching/version'
require 'view_component/fragment_caching/engine'
require 'view_component/fragment_caching/configuration'
require 'view_component/fragment_caching/compilers/inherited_template_compilation'
require 'view_component/fragment_caching/digestors/with_view_component_rb'
require 'view_component/fragment_caching/resolvers/view_component_resolver'
require 'view_component/fragment_caching/trackers/view_component_tracking'

require 'action_view'

module ViewComponent
  module FragmentCaching
    @configuration = Configuration.new

    class << self
      attr_reader :configuration

      delegate :view_component_paths, to: :configuration, private: true

      def configure
        yield configuration
      end

      def initialize!(context:)
        prepend_view_component_paths context
      end

      private

      def prepend_view_component_paths(context)
        Dir[*view_component_paths].each do |dir|
          resolver = Resolvers::ViewComponentResolver.new dir
          context.prepend_view_path resolver
        end
      end
    end
  end
end
