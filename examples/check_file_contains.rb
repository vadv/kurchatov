interval 60

default[:base_uri] = 'http://localhost/check'
default[:expression] = 'ERROR'
default[:contains] = false # Contains or not expression
default[:service] = "check_file_contains"

collect do
  event(
    :service => "#{plugin.service} #{plugin.base_uri} #{plugin.expression}",
    :description => "#{plugin.base_uri} contains #{plugin.expression}",
    :metric => rest_get(plugin.base_uri).include?(plugin.expression) == plugin.contains
  )
end
