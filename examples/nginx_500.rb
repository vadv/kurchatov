require 'file-tail'

interval 60
warning 10
critical 60
default[:check_interval] = 300
default[:check_last_lines] = 300
default[:file] = '/var/log/nginx/app-500.log'
default[:nginx_time_local] = "[^\\x20]+\\x20\\+\\d{4}\\]"

collect do

  def get_unix_time_from_line(text)
    match = text.match(plugin.nginx_time_local)
    return nil unless match
    time = parse_local_time(match[0]) rescue nil
    time
  end

  def parse_local_time(token)
    day, month, year, hour, minute, second, _ = token.split(/[\/: ]/) # работаем с local_time
    Time.local(year, month, day.gsub('[', ''), hour, minute, second).to_i
  end

  count_all = 0
  count_interval = 0
  file = File::Tail::Logfile.new(plugin.file)
  file.backward(plugin.check_last_lines)
  file.readlines.each do |line|
    line.force_encoding('UTF-8')
    next unless line.valid_encoding?
    time = get_unix_time_from_line(line)
    count_interval += 1 if time > (unixnow - plugin.interval)
    count_all += 1 if time > (unixnow - plugin.check_interval)
  end

  event(
      :service => "nginx log parse #{plugin.file} interval errors",
      :metric => count_all,
      :desc => "Count errors in file #{plugin.file}, last #{plugin.check_interval} sec"
  )
  event(
      :service => "nginx log parse #{plugin.file} realtime errors",
      :metric => count_interval,
      :state => 'ok',
      :desc => "Count errors in file #{plugin.file}, last #{plugin.interval} sec"
  )
end
