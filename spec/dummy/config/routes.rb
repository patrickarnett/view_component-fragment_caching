Rails.application.routes.draw do
  %w(tracked_dependencies untracked_dependencies).each do |namespace|
    %w(render_dependencies explicit_dependencies).each do |controller|
      %w(vc_has_own_view vc_inherits_view vc_child_has_view).each do |endpoint|
        get "#{namespace}/#{controller}/#{endpoint}", to: "#{namespace}/#{controller}##{endpoint}"
      end
    end
  end
end
