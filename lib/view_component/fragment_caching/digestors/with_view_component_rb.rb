module ViewComponent
  module FragmentCaching
    module Digestors
      module WithViewComponentRb
        class << self
          def prepended(mod)
            mod.singleton_class.prepend ClassMethods
          end
        end

        module ClassMethods
          def create(name, logical_name, template, partial)
            klass = partial ? ActionView::Digestor::Partial : ActionView::Digestor::Node
            children = ruby_nodes name, template, klass
            klass.new name, logical_name, template, children
          end

          private

          def ruby_nodes(name, template, klass)
            identifier = template.identifier
            if identifier.end_with?('.rb') ||
              !identifier.match?(view_component_path_regex) ||
              (component_class = name.classify.safe_constantize).nil?
              return []
            end

            view_component_ancestors(component_class).map do |ancestor|
              anc_identifier = ancestor.source_location
              anc_logical_name = ancestor.name.underscore
              view_component_ruby_node anc_identifier, anc_logical_name, template, klass
            end
          end

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

          def view_component_ancestors(component_class)
            ancestors = component_class.ancestors
            return [] unless ancestors.include? ViewComponent::Base

            ancestors.each_with_object([]) do |ancestor, memo|
              return memo if ancestor == ViewComponent::Base

              memo << ancestor if ancestor.is_a? Class
            end
          end

          def view_component_ruby_node(identifier, logical_name, template, klass)
            "#{identifier.split('.').first}.rb".then do |rb_identifier|
              next unless File.exist? rb_identifier

              rb_source = File.read rb_identifier
              rb_template = new_ruby_template rb_source, rb_identifier, template, logical_name
              klass.new logical_name, logical_name, rb_template, []
            end
          end

          def new_ruby_template(rb_source, rb_identifier, template, virtual_path)
            ActionView::Template.new rb_source,
                                     rb_identifier,
                                     template.handler,
                                     locals: template.locals,
                                     format: template.format,
                                     variant: template.variant,
                                     virtual_path: virtual_path
          end
        end
      end
    end
  end
end
