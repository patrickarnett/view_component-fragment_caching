module TrackedDependencies
  class ExplicitDependenciesController < ApplicationController
    def vc_has_own_view
      @component = Blogs::BlogComponent.new @blog
    end

    def vc_inherits_view
      @component = Blogs::ExtendedBlogComponent.new @blog
    end
  end
end
