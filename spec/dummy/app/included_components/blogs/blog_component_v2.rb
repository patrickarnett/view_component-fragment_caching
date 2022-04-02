module Blogs
  class BlogComponent < ViewComponent::Base
    def initialize(blog)
      super
      @blog = blog
    end

    private

    attr_reader :blog

    def ruby_version
      2
    end

    def child_ruby_version
      nil
    end
  end
end
