module ViewComponent
  module FragmentCaching
    class Engine < ::Rails::Engine
      isolate_namespace ViewComponent::FragmentCaching

      config.before_initialize do
        ActiveSupport.on_load :action_controller do
          next unless self == ActionController::Base

          ViewComponent::FragmentCaching.initialize! context: self
        end
      end

      config.after_initialize do
        ActionView::DependencyTracker::ERBTracker.prepend ViewComponent::FragmentCaching::Trackers::ViewComponentTracking

        if Rails.version >= '8.1'
          require 'action_view/dependency_tracker/ruby_tracker'
          ActionView::DependencyTracker::RubyTracker.prepend ViewComponent::FragmentCaching::Trackers::RubyViewComponentTracking
        end

        ActionView::Digestor::Node.prepend ViewComponent::FragmentCaching::Digestors::WithViewComponentRb

        ViewComponent::FragmentCaching::Resolvers::ViewComponentResolver::VIEW_COMPONENT_RUBY_HANDLER.tap do |vc_rb|
          ActionView::Template.register_template_handler vc_rb, ActionView::Template::Handlers::ERB.new
          ActionView::DependencyTracker.register_tracker vc_rb, ActionView::DependencyTracker::ERBTracker
        end
      end
    end
  end
end
