# encoding: utf-8

require 'ohai/system'
require 'mixlib/cli'
require 'kurchatov/version'
require 'kurchatov/config'
require 'kurchatov/log'
require 'kurchatov/mixin/init'
require 'kurchatov/plugin/config'
require 'kurchatov/monitor'

module Kurchatov
  class Application
    include Mixlib::CLI
    include Kurchatov::Mixin::Ohai
    include Kurchatov::Mixin::Monitor

    option :help,
           :short => '-h',
           :long => '--help',
           :description => 'Show this message',
           :on => :tail,
           :boolean => true,
           :show_options => true,
           :exit => 1

    option :version,
           :short => '-v',
           :long => '--version',
           :description => 'Show version',
           :boolean => true,
           :proc => lambda { |v| puts "Kurchatov: #{Kurchatov::VERSION}" },
           :exit => 0

    option :log_level,
           :short => '-l LEVEL',
           :long => '--log_level LEVEL',
           :description => 'Set the log level (debug, info, warn, error, fatal)',
           :proc => lambda { |l| l.to_sym }

    option :log_location,
           :short => '-L LOGLOCATION',
           :long => '--logfile LOGLOCATION',
           :description => 'Set the log file location'

    option :test_plugin,
           :short => '-T FILE',
           :long => '--test-plugin FILE',
           :description => 'Test plugin'

    option :config_file,
           :short => '-c FILE',
           :long => '--config FILE',
           :description => 'Config file'

    option :plugin_paths,
           :short => '-d DIR1,DIR2',
           :long => '--plugins DIR1,DIR2',
           :description => 'Plugin directories',
           :proc => lambda { |l| l.split(',') }

    option :ohai_plugins_paths,
           :short => '-o DIR1,DIR2',
           :long => '--ohai--plugins DIR1,DIR2',
           :description => 'Plugin directories',
           :proc => lambda { |l| l.split(',') }

    option :host,
           :long => '--host HOSTNAME',
           :description => 'Set hostname for events',
           :proc => lambda { |l| l.split(',') }

    option :tags,
           :short => '-t tag1,tag2,tag3',
           :long => '--tags tag1,tag2,tag3',
           :description => 'Set tags for events',
           :proc => lambda { |l| l.split(',') }

    option :riemann_responder,
           :short => '-H HOST1,HOST2:55655',
           :long => '--hosts HOST1,HOST2:55655',
           :description => 'Set riemann hosts for send events',
           :proc => lambda { |l| l.split(',') }

    option :http_responder,
           :long => '--http 0.0.0.0:55755',
           :description => 'Set http responder for information'

    option :udp_responder,
           :long => '--udp 0.0.0.0:55955',
           :description => 'Set udp responder for information'

    def configure_opts
      @attributes = parse_options
      @attributes = nil if @attributes.empty?
      Config.merge!(config)
    end

    def configure_logging
      Log.init(Config[:log_location])
      Log.level = Config[:log_level]
    end

    def configure_defaults
      ::Ohai::Config[:plugin_path] = [File.expand_path(File.join('..', 'ohai', 'plugins'), File.dirname(__FILE__))]
      if Config[:ohai_plugins_paths]
        ::Ohai::Config[:plugin_path] += Config[:ohai_plugins_paths]
      end
      Config[:host] ||= ohai[:fqdn] || ohai[:hostname]
    end

    def load_plugins(path)
      return if Config[:test_plugin]
      plugins = Kurchatov::Plugins::Config.load_plugins(path,
                                                        Config[:config_file])
      plugins.each {|p| monitor << p}
    end

    def configure_test_plugin
      return unless Config[:test_plugin]
      plugins = Kurchatov::Plugins::Config.load_test_plugin(Config[:test_plugin],
                                                        Config[:config_file])
      plugins.each {|p| monitor << p}
    end

    def run
      configure_opts
      configure_logging
      configure_defaults
      load_plugins(File.join(File.dirname(__FILE__),'responders'))
      load_plugins(Config[:plugin_paths])
      configure_test_plugin
      monitor.start!
    end

  end
end
