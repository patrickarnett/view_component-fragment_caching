module ViewComponent
  module FragmentCaching
    module Digestors
      module WithViewComponentRb
        def self.prepended(mod)
          mod.singleton_class.prepend ClassMethods
        end

        module ClassMethods
          def create(name, logical_name, template, partial)
            klass = partial ? ActionView::Digestor::Partial : ActionView::Digestor::Node
            identifier = template.identifier
            children =
              if identifier.include?('/app/components/') && !identifier.end_with?('.rb')
                rb_identifier = "#{identifier.split('.').first}.rb"
                begin
                  rb_source = File.read rb_identifier
                  rb_template = ActionView::Template.new(rb_source, rb_identifier, template.handler, locals: template.locals, format: template.format, variant: template.variant, virtual_path: template.virtual_path)
                  rb_node = klass.new(name, logical_name, rb_template, [])
                  [rb_node]
                rescue Errno::ENOENT
                end
              end
            klass.new(name, logical_name, template, children || [])
          end
        end
      end
    end
  end
end
