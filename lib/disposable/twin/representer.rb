require "representable/decorator"
require "representable/hash"
require "representable/hash/allow_symbols"

module Disposable
  class Twin
    class Decorator < Representable::Decorator
      # Overrides representable's Definition class so we can add semantics in our representers.
      class Definition < Representable::Definition
        def dynamic_options
          super + [:twin]
        end

        def twin_class
          self[:twin].evaluate(nil) # FIXME: do we support the :twin option, and should it be wrapped?
        end
      end


      # DISCUSS: same in reform, is that a bug in represntable?
      def self.clone # called in inheritable_attr :representer_class.
        Class.new(self) # By subclassing, representable_attrs.clone is called.
      end

      # FIXME: this is not properly used when inheriting - fix that in representable.
      def self.build_config
        Config.new(Definition)
      end

      def self.each(only_nested=true, &block)
        definitions = representable_attrs
        definitions = representable_attrs.find_all { |attr| attr[:twin] } if only_nested

        definitions.each(&block)
        self
      end

      def self.default_inline_class
        Disposable::Twin
      end


      # TODO: check how to simplify.
      class Options < ::Hash
        def include!(names)
          includes.push(*names) #if names.size > 0
          self
        end

        def exclude!(names)
          excludes.push(*names) #if names.size > 0
          self
        end

        def excludes
          self[:exclude] ||= []
        end

        def includes
          self[:include] ||= []
        end
      end
    end

  end
end