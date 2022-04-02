module ViewComponent
  module FragmentCaching
    class Engine < ::Rails::Engine
      isolate_namespace ViewComponent::FragmentCaching
    end
  end
end
