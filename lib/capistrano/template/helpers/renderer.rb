# frozen_string_literal: true

module Capistrano
  module Template
    module Helpers
      class Renderer < SimpleDelegator
        attr_accessor :from, :reader
        attr_reader :locals

        def initialize(from, context, reader: File, locals: {})
          super(context)

          self.from = from
          self.reader = reader
          self.locals = locals
        end

        def locals=(new_locals)
          new_locals ||= {}
          new_locals = new_locals.transform_keys(&:to_sym)
          @locals = new_locals
        end

        def rendered_template
          @rendered_template ||= ERB.new(template_content, trim_mode: "-").result(Kernel.binding)
        end

        def as_str
          rendered_template
        end

        def as_io
          StringIO.new(as_str)
        end

        def method_missing(method_name, *args, &block)
          if locals.key?(method_name)
            locals[method_name]
          else
            super
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          locals.key?(method_name) || super
        end

        def render(from, indent: 0, locals: {})
          template = template_file(from)
          content  = Renderer.new(template, self, reader: reader, locals: self.locals.merge(locals)).as_str

          indented_content(content, indent)
        end

        def indented_content(content, indent)
          content.split("\n").map { |line| "#{' ' * indent}#{line}" }.join("\n")
        end

        protected

        def template_content
          reader.read(from)
        end
      end
    end
  end
end
