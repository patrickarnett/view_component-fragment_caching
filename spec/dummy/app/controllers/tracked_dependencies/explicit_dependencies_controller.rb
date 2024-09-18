module TrackedDependencies
  class ExplicitDependenciesController < ApplicationController
    def vc_has_own_view
      @component = Blogs::Blog::Component.new @blog
    end

    def vc_inherits_view
      @component = Blogs::ExtendedBlogComponent.new @blog
    end

    def vc_child_has_view
      @component = Blogs::ExtendedWithViewBlogComponent.new @blog
    end
  end
end
