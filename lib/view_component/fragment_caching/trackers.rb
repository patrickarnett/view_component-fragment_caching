module ViewComponent
  module FragmentCaching
    module Trackers
      EXPLICIT_VIEW_COMPONENT_DEPENDENCY = /# View Component Dependency: (\S+)/.freeze
      private_constant :EXPLICIT_VIEW_COMPONENT_DEPENDENCY

      CAMEL_PHRASE = /(?:([A-Z]+[a-z]*[0-9]*)+)/.freeze
      private_constant :CAMEL_PHRASE

      MODULE_NAME = /(?:((::)?#{CAMEL_PHRASE}+)+)/.freeze
      private_constant :MODULE_NAME

      VIEW_COMPONENT_NAME = /(?:#{MODULE_NAME}?(::)?Component)/.freeze
      private_constant :VIEW_COMPONENT_NAME

      MODULE_NAME_END = /(?:\b[^:])/.freeze
      private_constant :MODULE_NAME_END

      INVOKE_METHOD = /(?:\s*\.\s*(((public_)?send?(\s*\(?\s*):)?))/.freeze
      private_constant :INVOKE_METHOD

      INITIALIZE_METHOD_NAME = /(?:\b(new|with_collection)\b)/.freeze
      private_constant :INITIALIZE_METHOD_NAME

      VIEW_COMPONENT_RENDER_ARGUMENTS = /
          \A
          (?:\s*\(?\s*)
          (?<view_component>#{VIEW_COMPONENT_NAME})
          (?:#{INVOKE_METHOD})
          (?:#{INITIALIZE_METHOD_NAME})
        /xm.freeze
      private_constant :VIEW_COMPONENT_RENDER_ARGUMENTS

      CLASS_INHERITANCE = /(?:\s*\bclass\s+#{MODULE_NAME}\s*<\s*)/.freeze
      private_constant :CLASS_INHERITANCE

      VIEW_COMPONENT_INHERITANCE_DEPENDENCY = /
          (?:#{CLASS_INHERITANCE})
          (?<view_component>#{VIEW_COMPONENT_NAME})
          (?:#{MODULE_NAME_END})
        /xm.freeze
      private_constant :VIEW_COMPONENT_INHERITANCE_DEPENDENCY
    end
  end
end
