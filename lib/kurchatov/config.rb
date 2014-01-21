require "mixlib/config"

module Kurchatov
  class Config
    extend Mixlib::Config
    default :log_level, :info
    default :log_location, STDERR
    default :plugin_paths, ['/usr/share/kurchatov/plugins']
    default :config_file, '/etc/kurchatov/config.yml'
    # errors
    default :ERROR_CONFIG, 2
    default :ERROR_PLUGIN_REQ, 3
  end
end
