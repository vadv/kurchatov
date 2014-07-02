module Kurchatov
  class Monitor

    class Task
      include Kurchatov::Mixin::Event
      attr_accessor :thread, :instance
      attr_reader :count_errors, :last_error, :last_error_at

      def initialize(plugin)
        @plugin = plugin
        @thread = Thread.new { @plugin.start! }
        @count_errors = 0
        @last_error = nil
        @last_error_at = nil
        @last_error_count = 0
      end

      def name
        @plugin.name
      end

      def config
        @plugin.plugin_config
      end

      def stop!
        Thread.kill(@thread)
      end

      def stopped?
        @plugin.stopped?
      end

      def died?
        if @thread.alive?
          @last_error_count = 0
          return false 
        end
        # thread died, join and extract error
        begin
          @thread.join # call error
        rescue => e
          desc = "Plugin '#{@plugin.name}' died. #{e.class}: #{e}.\n" +
            "Trace:  #{e.backtrace.join("\n")}"
          @count_errors += 1
          @last_error_count += 1
          @last_error = desc
          @last_error_at = Time.now
          Log.error(desc)
          if @plugin.ignore_errors == false || (@plugin.ignore_errors.class == 'Fixnum' && @plugin.ignore_errors > @plugin.last_error_count)
            event(:service => "plugin #{@plugin.name} errors", :desc => desc, :state => 'critical')
          end
        end
        true
      end

      def start!
        @thread = Thread.new { @plugin.start! }
      end

    end

    attr_accessor :tasks
    CHECK_ALIVE_TIMEOUT = 5

    def initialize
      @tasks = Array.new
    end

    def <<(plugin)
      Log.debug("Add new plugin: #{plugin.inspect}")
      @tasks << Task.new(plugin)
    end

    def start!
      loop do
        @tasks.each do |task|
          task.start! if task.died?
          if task.stopped?
            task.stop!
            @tasks.delete(task)
          end
        end
        Log.debug("Check alive plugins [#{@tasks.count}]")
        sleep CHECK_ALIVE_TIMEOUT
      end
    end

    def inspect
      @tasks.map do |t|
        {
          "name" => t.name,
          "config" => t.config,
          "errors" => {"count" => t.count_errors, "last" => t.last_error, "time" => t.last_error_at}
        }
      end
    end

  end
end
