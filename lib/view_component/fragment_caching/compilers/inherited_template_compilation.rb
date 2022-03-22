module ViewComponent
  module FragmentCaching
    module Compilers
      module InheritedTemplateCompilation
        private

        def templates
          @templates ||=
            begin
              extensions = ActionView::Template.template_handler_extensions

              check_class = component_class
              files =
                loop do
                  break [] if check_class == ViewComponent::Base || !check_class.respond_to?(:_sidecar_files)

                  files = check_class._sidecar_files extensions
                  break files if files.present?

                  check_class = check_class.superclass
                end

              files.map do |path|
                pieces = File.basename(path).split '.'
                {
                  path: path,
                  variant: pieces.second.split('+').second&.to_sym,
                  handler: pieces.last
                }
              end
            end
        end
      end
    end
  end
end
