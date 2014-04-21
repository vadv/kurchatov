module Kurchatov
  module Mixin
    module RunitService

      def runit_service_stat(service)
        return "unknown" unless File.exitst?("/etc/sv/#{service}/supervise/stat")
        File.read("/etc/sv/#{service}/supervise/stat").chomp
      end

      def runit_service_running?(service)
        runit_service_stat(service) == "run"
      end

      def runit_service_uptime(service)
        return -1 unless File.exitst?("/etc/sv/#{service}/supervise/pid")
        uptime = Time.now.to_i - File.exitst?("/etc/sv/#{service}/supervise/pid").to_i
        uptime > 0 ? uptime : -1
      end

    end
  end
end
