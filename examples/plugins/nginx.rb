always_start true
interval 60

default[:file] = '/etc/nginx/sites-enabled/status'
default[:url] = 'http://127.0.0.1:11311/status'
default[:nginx_status_1] = %W(accepts handled requests)
default[:nginx_status_2] = %W(reading writing waiting)

run_if do
  File.exists? plugin.file
end

collect :os => 'linux' do
  lines = http_get(plugin.url).split("\n")
  lines[2].scan(/\d+/).each_with_index do |value, index|
    event(:service => "nginx #{plugin.nginx_status_1[index]}", :metric => value.to_f/interval, :diff => true)
  end
  event(:service => 'nginx active', :metric => lines[0].split(':')[1].strip.to_i)
  lines[3].scan(/\d+/).each_with_index do |value, index|
    event(:service => "nginx #{plugin.nginx_status_2[index]}", :metric => value.to_i)
  end
end
