module Kurchatov
  class Monitor

    class Task
      include Kurchatov::Mixin::Event
      include Kurchatov::Mixin::Queue
      attr_accessor :thread, :instance

      def initialize(plugin)
        @plugin = plugin
        @thread = Thread.new { @plugin.run }
      end

      def died?
        return false if @thread.alive?
        # thread died, join and extract error
        begin
          @thread.join # call error
        rescue => e
          desc = "Plugin '#{@plugin.name}' died. #{e.class}: #{e}\n #{e.backtrace.join("\n")}"
          Log.error(desc)
          event(:service => "riemann client errors", :desc => desc, :state => 'critical')
        end
        @thread = Thread.new { @plugin.run }
        true
      end

      def status
        {@plugin.name => @thread.alive?}
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

    def tasks_status
      @tasks.map {|t| t.status }
    end

  end
end
