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
            children = Array.wrap view_component_ruby_node(identifier, logical_name, template, klass)
            klass.new name, logical_name, template, children
          end

          private

          def view_component_path_regex
            @view_component_path_regex ||=
              begin
                paths =
                  ViewComponent::FragmentCaching.view_component_paths.map do |path|
                    "/#{path}/".gsub Regexp.new('/{2,}'), '/'
                  end
                Regexp.new paths.join '|'
              end
          end

          def view_component_ruby_node(identifier, logical_name, template, klass)
            return if identifier.end_with?('.rb') || !identifier.match?(view_component_path_regex)

            "#{identifier.split('.').first}.rb".then do |rb_identifier|
              next unless File.exist? rb_identifier

              rb_source = File.read rb_identifier
              rb_template = new_ruby_template rb_source, rb_identifier, template
              klass.new name, logical_name, rb_template, []
            end
          end

          def new_ruby_template(rb_source, rb_identifier, template)
            ActionView::Template.new rb_source,
                                     rb_identifier,
                                     template.handler,
                                     locals: template.locals,
                                     format: template.format,
                                     variant: template.variant,
                                     virtual_path: template.virtual_path
          end
        end
      end
    end
  end
end
