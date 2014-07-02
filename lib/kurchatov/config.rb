module Kurchatov
  class Config
    extend Mixlib::Config
    default :log_level, :info
    default :log_location, STDERR
    default :plugin_paths, ['/usr/share/kurchatov/plugins']
    default :config_file, '/etc/kurchatov/config.yml'
    # errors
    default :ERROR_CONFIG, 2
  end
end
