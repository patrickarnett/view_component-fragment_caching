module ViewComponent
  module FragmentCaching
    module Compilers
      module InheritedTemplateCompilation
        private

        def templates
          @templates ||= __vc_fc_files.map(&method(:__vc_fc_file_metadata))
        end

        def __vc_fc_files
          templates = []
          check_class = component_class
          check_extensions = ActionView::Template.template_handler_extensions.dup
          loop do
            break if check_class == ViewComponent::Base || !check_class.respond_to?(:_sidecar_files) || check_extensions.empty?

            files = check_class._sidecar_files check_extensions
            if files.present?
              templates += files
              check_extensions -= files.map(&File.method(:extname))
            end

            check_class = check_class.superclass
          end
          templates
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
