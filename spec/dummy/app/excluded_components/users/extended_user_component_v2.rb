module Users
  class ExtendedUserComponent < Users::UserComponent
    private

    def child_ruby_version
      2
    end
  end
end
