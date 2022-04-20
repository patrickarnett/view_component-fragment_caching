module UntrackedDependencies
  class ExplicitDependenciesController < ApplicationController
    def vc_has_own_view
      @component = Users::UserComponent.new @blog
    end

    def vc_inherits_view
      @component = Users::ExtendedUserComponent.new @blog
    end
  end
end
