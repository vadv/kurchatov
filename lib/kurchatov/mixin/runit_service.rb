module Kurchatov
  module Mixin
    module RunitService

      def runit_service_stat(service)
        return "unknown" unless File.exitst?("/etc/sv/#{service}/supervise/stat")
        File.read("/etc/sv/#{service}/supervise/stat")
      end

    end
  end
end
