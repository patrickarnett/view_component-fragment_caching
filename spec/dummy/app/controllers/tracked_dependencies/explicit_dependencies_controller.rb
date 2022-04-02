module TrackedDependencies
  class ExplicitDependenciesController < ApplicationController
    before_action :load_component

    def vc_has_own_view; end
    def vc_inherits_view; end

    private

    def load_component
      @component = Blogs::BlogComponent.new @blog
    end
  end
end
