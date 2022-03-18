require 'view_component/fragment_caching/version'
require 'view_component/fragment_caching/engine'
require 'view_component/fragment_caching/configuration'
require 'view_component/fragment_caching/resolvers/view_component_resolver'

require 'action_view'

module ViewComponent
  module FragmentCaching
    CONFIGURATION = Configuration.new
    private_constant :CONFIGURATION

    class << self
      delegate :view_component_paths, to: :configuration

      def config
        yield configuration
      end

      def initialize!(context:)
        prepend_view_component_paths context
      end

      private

      def configuration
        CONFIGURATION
      end

      def prepend_view_component_paths(context)
        Dir[*view_component_paths].each do |dir|
          resolver = Resolvers::ViewComponentResolver.new dir
          context.prepend_view_path resolver
        end
      end
    end
  end
end
