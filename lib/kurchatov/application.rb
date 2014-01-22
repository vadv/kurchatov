# encoding: utf-8

require "ohai/system"
require "mixlib/cli"
require "kurchatov/version"
require "kurchatov/config"
require "kurchatov/log"
require "kurchatov/mixin/init"
require "kurchatov/plugin/config"
require "kurchatov/responders/init"
require "kurchatov/monitor"

module Kurchatov
  class Aplication
    include Mixlib::CLI
    include Kurchatov::Mixin::Ohai

    option :help,
      :short        => "-h",
      :long         => "--help",
      :description  => "Show this message",
      :on           => :tail,
      :boolean      => true,
      :show_options => true,
      :exit         => 1

    option :version,
      :short        => "-v",
      :long         => "--version",
      :description  => "Show version",
      :boolean      => true,
      :proc         => lambda {|v| puts "Kurchatov: #{Kurchatov::VERSION}"},
      :exit         => 0

    option :log_level,
      :short        => "-l LEVEL",
      :long         => "--log_level LEVEL",
      :description  => "Set the log level (debug, info, warn, error, fatal)",
      :proc         => lambda {|l| l.to_sym}

    option :log_location,
      :short        => "-L LOGLOCATION",
      :long         => "--logfile LOGLOCATION",
      :description  => "Set the log file location"

    option :test_plugin,
      :short        => "-T FILE",
      :long         => "--test-plugin FILE",
      :description  => "Test plugin"

    option :config_file,
      :short        => "-c FILE",
      :long         => "--config FILE",
      :description  => "Config file"

    option :plugin_paths,
      :short        => "-d DIR1,DIR2",
      :long         => "--plugins DIR1,DIR2",
      :description  => "Plugin directories",
      :proc         => lambda {|l| l.split(',') }

    option :ohai_plugins_paths,
      :short        => "-o DIR1,DIR2",
      :long         => "--ohai--plugins DIR1,DIR2",
      :description  => "Plugin directories",
      :proc         => lambda {|l| l.split(',') }

    option :host,
      :long         => "--host HOSTNAME",
      :description  => "Set hostname for events",
      :proc         => lambda {|l| l.split(',') }

    option :tags,
      :short        => "-t tag1,tag2,tag3",
      :long         => "--tags tag1,tag2,tag3",
      :description  => "Set tags for events",
      :proc         => lambda {|l| l.split(',') }

    option :riemann_responder,
      :short        => "-H HOST1,HOST2:55655",
      :long         => "--hosts HOST1,HOST2:55655",
      :description  => "Set riemann hosts for send events",
      :proc         => lambda {|l| l.split(',') }

    option :http_responder,
      :long         => "--http 0.0.0.0:55755",
      :description  => "Set http responder for information"

    option :udp_responder,
      :long         => "--udp 0.0.0.0:55955",
      :description  => "Set udp responder for information"

    option :stop_on_error,
      :long         => "--stop-on-error",
      :description  => "Stop on plugin or connection problem",
      :boolean      => true,
      :proc         => lambda {|l| !!l }

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
      ::Ohai::Config[:plugin_path] = [ File.expand_path(File.join('..', 'ohai', 'plugins'), File.dirname(__FILE__)) ]
      if Config[:ohai_plugins_paths]
        ::Ohai::Config[:plugin_path] += Config[:ohai_plugins_paths]
      end
      Config[:host] ||= ohai[:fqdn] || ohai[:hostname]
    end

    def configure_responders
      return if Config[:test_plugin]
      Log.error("Please set riemann host") and exit Config[:ERROR_CONFIG] unless 
        Config[:riemann_responder]
      if Config[:udp_responder]
        @monitor << Responders::Udp.new( Config[:udp_responder] )
      end
      if Config[:http_responder]
        @monitor << Responders::Http.new( Config[:http_responder] )
      end
      @monitor << Responders::Riemann.new( Config[:riemann_responder] )
    end 

    def configure_plugins
      return if Config[:test_plugin]
      plugins = Kurchatov::Plugins::Config.load_plugins(Config[:plugin_paths], 
                                                        Config[:config_file])
      plugins.each {|p| @monitor << p }
    end

    def configure_test_plugin
      return if !Config[:test_plugin]
      @monitor << Kurchatov::Plugins::DSL.load_riemann_plugin(Config[:test_plugin])
    end

    def run
      configure_opts
      configure_logging
      configure_defaults
      @monitor = Monitor.new(Config[:stop_on_error] || !!Config[:test_plugin])
      configure_responders
      configure_plugins
      configure_test_plugin
      @monitor.run
    end
    
  end
end
