module Kurchatov
  class Monitor

    class Task
      include Kurchatov::Mixin::Event
      attr_accessor :thread, :instance

      def initialize(plugin)
        @plugin = plugin
        @thread = Thread.new { @plugin.run }
      end

      def status
        !!@thread.alive?
      end

      def name
        @plugin.name
      end

      def type
        @plugin.class.to_s
      end

      def uptime
        @plugin.uptime
      end

      def died?
        return false if @thread.alive?
        # thread died, join and extract error
        begin
          @thread.join # call error
        rescue => e
          desc = "Plugin '#{@plugin.name}' died. #{e.class}: #{e}\n." +
            "Trace:  #{e.backtrace.join("\n")}"
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
      @tasks.map {|t| {name: t.name, alive: t.status, type: t.type, uptime: t.uptime}  }
    end

  end
end
