module Kurchatov
  module Mixin
    module Command

      def shell_out(cmd)
        mix = ::Mixlib::ShellOut.new(cmd)
        mix.run_command
        mix
      end

      def shell_out!(cmd)
        mix = shell_out(cmd)
        mix.error!
        mix
      end

      def shell(cmd)
        mix = shell_out!(cmd)
        mix.stdout
      end

      def print_unix_mem_info
        pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
        puts "Pid: #{pid}, memusage: #{size}"
      end

    end
  end
end
