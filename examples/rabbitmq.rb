default[:api_url] = 'http://admin:admin@127.0.0.1:55672/api'
default[:vhost] = ['notexists']

collect do
  plugin.vhosts.each do |vhost|
    vhost_uri = "#{plugin.api_url}/queues/#{CGI.escape(vhost)}"
    JSON.parse(rest_get(vhost_uri)).each do |queue|
      event(
        :service => "rabbitmq queue #{queue['name'].gsub('.', '_')} messages count",
        :metric => queue['messages'].to_i,
        :desc => "Rabbitmq queue count in #{queue['name']}",
        :critical => 1000
      )
    end
  end
end
