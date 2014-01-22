module Kurchatov
  module Plugins
    class DSL

      include Kurchatov::Mixin::Ohai

      attr_reader :plugins
      PLUGIN_EXT = '.rb'

      def initialize
        @plugins = Array.new
      end

      def last
        @plugins.last
      end

      # plugins dsl part
      def always_start(val)
        last.always_start = !!val
      end

      def interval(val)
        last.interval = val.to_f
      end

      def name(val)
        last.name = val
      end

      def critical(val)
        last.plugin[:critical] = val
      end

      def warning(val)
        last.plugin[:warning] = val
      end

      def collect(opts = {}, *args, &block)
        return unless last.respond_to_ohai?(opts)
        last.collect = block
      end

      def run_if(opts = {}, &block)
        return unless last.respond_to_ohai?(opts)
        last.run_if = block
      end

      def last_plugin
        last.plugin
      end

      alias :default :last_plugin


      # load part

      def self.load_riemann_plugins(paths)
        dsl = Kurchatov::Plugins::DSL.new
        paths.map do |path|
          Log.error("Directory #{path} not found") and
              exit(Kurchatov::Config[:ERROR_CONFIG]) unless File.directory?(path)
          Dir["#{path}/*#{PLUGIN_EXT}"].sort
        end.flatten.each do |path|
          begin
            dsl.plugins << Kurchatov::Plugins::Riemann.new(File.basename(path, PLUGIN_EXT))
            dsl.instance_eval(File.read(path), path)
          rescue LoadError, SyntaxError => e
            dsl.plugins.pop # todo: plugin.new creates
            Log.error("Load plugin from file #{path}, #{e.class}: #{e}\n #{e.backtrace.join("\n")}")
          end
        end
        dsl.plugins
      end

      def self.load_riemann_plugin(file)
        dsl = Kurchatov::Plugins::DSL.new
        dsl.plugins << Kurchatov::Plugins::Riemann.new(File.basename(file, PLUGIN_EXT))
        dsl.instance_eval(File.read(file), file)
        dsl.last
      end

    end
  end
end
