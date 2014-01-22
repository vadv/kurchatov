module Kurchatov
  class Log
    extend Mixlib::Log
    init(Config[:log_location])
    level = Config[:log_level]
  end
end
