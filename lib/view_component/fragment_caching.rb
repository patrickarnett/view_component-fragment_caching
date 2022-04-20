require 'action_view/dependency_tracker/erb_tracker'
Dir[File.expand_path './fragment_caching/**/*.rb', __dir__].sort.each(&method(:require))

module ViewComponent
  module FragmentCaching
    class << self
      delegate :view_component_paths, to: :configuration

      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield configuration
      end

      def initialize!(context:)
        prepend_view_component_paths context
      end

      private

      def prepend_view_component_paths(context)
        full_paths = view_component_paths.map(&Rails.root.method(:join))
        Dir[*full_paths].each do |dir|
          resolver = Resolvers::ViewComponentResolver.new dir
          context.prepend_view_path resolver
        end
      end
    end
  end
end
