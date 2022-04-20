module ViewComponent
  module FragmentCaching
    module Compilers
      module InheritedTemplateCompilation
        private

        def templates
          @templates ||= __vc_fc_files.map(&method(:__vc_fc_file_metadata))
        end

        def __vc_fc_files
          check_class = component_class
          loop do
            break [] if check_class == ViewComponent::Base || !check_class.respond_to?(:_sidecar_files)

            files = check_class._sidecar_files ActionView::Template.template_handler_extensions
            break files if files.present?

            check_class = check_class.superclass
          end
        end

        def __vc_fc_file_metadata(path)
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
