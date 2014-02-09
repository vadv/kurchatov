default[:url] = 'http://localhost/sidekiq/queue-state'

collect do
  event(
      :service => "#{name} #{plugin.url}",
      :metric => rest_get(plugin.url).strip == 'OK',
      :description => "sidekiq queue status #{plugin.url}"
  )
end
