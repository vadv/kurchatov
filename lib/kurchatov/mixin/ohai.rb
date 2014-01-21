module Kurchatov

  module Ohai
    def self.data
      @ohai ||= ::Ohai::System.new
      Log.info("Load ohai plugins")
      @ohai.all_plugins
      @ohai.data
    end
  end

  module Mixin
    module Ohai
      class << self; attr_accessor :ohai_instance; end
      def ohai
        @ohai_instance ||= Kurchatov::Mixin::Ohai.ohai_instance ||= Kurchatov::Ohai.data
      end
    end
  end

end

