ActiveSupport.on_load :action_controller do
  next unless self == ActionController::Base

  ViewComponent::FragmentCaching.initialize! context: self
end

Rails.application.reloader.to_prepare do
  ActiveSupport.on_load :action_view do
    ActiveSupport.on_load :after_initialize do
      ActionView::DependencyTracker::ERBTracker.prepend ViewComponent::FragmentCaching::Trackers::ViewComponentTracking
      ActionView::Digestor::Node.prepend ViewComponent::FragmentCaching::Digestors::WithViewComponentRb

      ViewComponent::FragmentCaching::Resolvers::ViewComponentResolver::VIEW_COMPONENT_RUBY_HANDLER.tap do |vc_rb|
        ActionView::Template.register_template_handler vc_rb, ActionView::Template::Handlers::ERB.new
        ActionView::DependencyTracker.register_tracker vc_rb, ActionView::DependencyTracker::ERBTracker
      end
    end
  end
end
