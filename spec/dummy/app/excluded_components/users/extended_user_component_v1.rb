module Users
  class ExtendedUserComponent < Users::UserComponent
    private

    def child_ruby_version
      1
    end
  end
end
