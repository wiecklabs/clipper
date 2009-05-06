module Clipper
  module Hooks

    def self.included(target)
      target.extend(ClassMethods)

      target.class_eval do
        @__clipper_hooked_method_added = method(:method_added) if respond_to?(:method_added)
        def self.method_added(method)
          @__clipper_hooked_method_added.call(method) if @__clipper_hooked_method_added
        end
      end

    end

    class Map
      def initialize(target)
        @map = {}
        @target = target
      end

      def [](method_name)
        @map[method_name] ||= Chain.new(@target, method_name)
      end
    end

    class Chain
      def initialize(target, method_name)
        @target = target
        @method_name = method_name
        @before = java.util.LinkedHashSet.new
        @after = java.util.LinkedHashSet.new

        Chain.bind!(target, method_name)
      end

      def before(block)
        @before << block
      end

      def after(block)
        @after << block
      end

      def call(instance, args, blk = nil)
        @before.each do |block|
          block.call instance
        end

        result = instance.send("__hooked_#{@method_name}", *args, &blk)

        @after.each do |block|
          block.call instance
        end

        result
      end

      def self.bind!(target, method_name)
        target.send(:alias_method, "__hooked_#{method_name}", method_name)

        target.send(:class_eval, <<-EOS)
          def #{method_name}(*args, &block)
            self.class.hooks[#{method_name.inspect}].call(self, args, block)
          end
        EOS

        # or add_a_method_added_hook_for_this_method_if_it_doesnt_already_exist
      end
    end

    module ClassMethods

      def hooks
        @hooks ||= Map.new(self)
      end

      def before(method_name, &block)
        hooks[method_name].before(block)
      end

      def after(method_name, &block)
        hooks[method_name].after(block)
      end

    end
  end
end