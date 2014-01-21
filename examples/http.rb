interval 60

default[:http_code] = 200
default[:http_method] = 'GET'
default[:connect_timeout] = 5
default[:retry] = 0
default[:retry_delay] = 0
default[:max_time] = 10
default[:insecure] = false
default[:url] = 'http://127.0.0.1:80'
default[:service] = 'http check'

collect do

  @cmd ||= begin
    "curl -X#{plugin.http_method} -s --connect-timeout #{plugin.connect_timeout}" +
      " #{'--insecure' if plugin.insecure} " +
      " -w '%{http_code}\\n' --retry #{plugin.retry} --retry-delay #{plugin.retry_delay}" +
      " --max-time #{plugin.max_time} --fail #{plugin.url} -o /dev/null"
  end

  out = shell_out(@cmd).stdout.to_i
  event(:service => plugin.service, :metric => out, :description => "http code: #{out}", :state => out == plugin.http_code)

end
