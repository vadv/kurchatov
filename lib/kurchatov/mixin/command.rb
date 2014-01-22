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

    end
  end
end
