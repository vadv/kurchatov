default[:url] = 'http://localhost/admin/sidekiq/dashboard/stats'

collect do
  stats = JSON.parse(rest_get(plugin.url))
  stats = stats['sidekiq'] ? stats['sidekiq'] : stats
  event(
      :service => "#{name} #{plugin.url}",
      :metric => stats['enqueued'].to_i,
      :description => "sidekiq queue from #{plugin.url}",
      :warning => 10,
      :critical => 60
  )
  event(
      :service => "#{name} #{plugin.url}",
      :metric => stats['failed'].to_i,
      :diff => true,
      :description => "sidekiq failed from #{plugin.url}",
      :warning => 10,
      :critical => 60
  )
end
