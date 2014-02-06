module Kurchatov
  class Monitor

    class Task
      include Kurchatov::Mixin::Event
      attr_accessor :thread, :instance
      attr_reader :count_errors, :last_error, :last_error_at

      def initialize(plugin)
        @plugin = plugin
        @thread = Thread.new { @plugin.run }
        @count_errors = 0
        @last_error = nil
        @last_error_at = nil
      end

      def name
        @plugin.name
      end

      def type
        @plugin.class.to_s
      end

      def config
        @plugin.plugin_config
      end

      def died?
        return false if @thread.alive?
        # thread died, join and extract error
        begin
          @thread.join # call error
        rescue => e
          desc = "Plugin '#{@plugin.name}' died. #{e.class}: #{e}\n." +
            "Trace:  #{e.backtrace.join("\n")}"
          @count_errors += 1
          @last_error = desc
          @last_error_at = Time.now
          Log.error(desc)
          unless @plugin.ignore_errors
            event(:service => 'riemann client errors', :desc => desc, :state => 'critical')
          end
        end
        @thread = Thread.new { @plugin.run }
        true
      end

    end

    attr_accessor :tasks
    CHECK_ALIVE_TIMEOUT = 5

    def initialize(stop = false)
      @stop_on_error = stop
      @tasks = Array.new
    end

    def <<(plugin)
      Log.debug("Add new plugin: #{plugin.inspect}")
      @tasks << Task.new(plugin)
    end

    def run
      loop do
        @tasks.each { |t| exit Config[:ERROR_PLUGIN_REQ] if t.died? && @stop_on_error }
        Log.debug("Check alive plugins [#{@tasks.count}]")
        sleep CHECK_ALIVE_TIMEOUT
      end
    end

    def inspect
      @tasks.map do |t|
        {
          "name" => t.name,
          "type" => t.type,
          "config" => t.config,
          "errors" => {"count" => t.count_errors, "last" => t.last_error, "time" => t.last_error_at}
        }
      end
    end

  end
end
