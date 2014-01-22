require "kurchatov/plugin/riemann"
require "kurchatov/plugin/dsl"
require "yaml"

module Kurchatov
  module Plugins
    module Config

      def self.find_plugin(name, array)
        array.find {|p| p.name == name }
      end

      def self.load_plugins(plugins_path, config_file)
        Log.error("Config file #{config_file} not found") and exit Kurchatov::Config[:ERROR_CONFIG] unless File.exists?(config_file)
        @all_plugins = Kurchatov::Plugins::DSL.load_riemann_plugins(plugins_path)
        @all_names = Array.new
        @plugins_to_run = Array.new
        config = YAML.load_file(config_file)
        config.each do |name, val|
          @all_names << name
          next if val.nil?
          #
          # dup plugins from array
          #
          if val.kind_of? Array
            parent = find_plugin(name, @all_plugins)
            Log.error("Unable to find parent plugin for #{name}") and next if parent.nil?
            val.each_with_index do |p_settings, i|
              child = parent.dup
              child.name = "#{name}_#{i}"
              child.plugin = parent.plugin.dup
              child.plugin.merge!(p_settings)
              @all_plugins << child
              @all_names << child.name
            end
            @all_plugins.delete(parent)
            next
          end
          #
          # dup plugins from 'parent'
          #
          if val.is_a?(Hash) && val.has_key?('parent')
            parent = find_plugin(val['parent'], @all_plugins)
            Log.error("Unable to find parent '#{parent}' for '#{name}'") and next if parent.nil?
            child = parent.dup
            child.name = name
            child.plugin = parent.plugin.dup
            child.plugin.merge!(val)
            @all_plugins << child
            @all_names << child.name
            next
          end
          @all_plugins.each { |p| p.plugin.merge!(val) if name == p.name }
        end
        @all_plugins.each do |p|
          unless p.always_start || @all_names.include?(p.name)
            Log.info("Plugin '#{p.name}' not started, because it " +
                                "not 'always_start' and not in config file")
            next
          end
          @plugins_to_run << p if p.runnable_by_config?
        end
        Log.debug("Plugins to start: #{@plugins_to_run.inspect}")
        @plugins_to_run
      end

    end
  end
end
