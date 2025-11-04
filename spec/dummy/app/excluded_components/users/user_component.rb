module Users
  class UserComponent < ViewComponent::Base
    def initialize(user)
      super()
      @user = user
    end

    private

    attr_reader :user

    def ruby_version
      1
    end

    def child_ruby_version
      nil
    end
  end
end
