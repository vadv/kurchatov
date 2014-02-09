interval 60

run_if do
  File.exists? '/proc/mdstat'
end

collect do

  def rm_bracket(text)
    text.gsub('[', '').gsub(']', '')
  end

  def status_well?(text)
    text.gsub(/U/, '').empty?
  end

  def get_failed_parts (device)
    begin
      failed_parts = []
      Dir["/sys/block/#{device}/md/dev-*"].each do |p|
        state = File.read("#{p}/state").strip
        next unless state != 'in_sync'
        p.gsub!(/.+\/dev-/, '')
        failed_parts << "#{p} (#{state})"
      end
      failed_parts.join(', ')
    rescue
      nil
    end
  end


  mdstat = File.read('/proc/mdstat').split("\n")
  mdstat.each_with_index do |line, index|
    next unless line.include?('blocks')
    device = file[index-1].split(':')[0].strip
    mdstatus = rm_bracket(line.split(' ').last) # UUU
    next if status_well?(mdstatus) # пропускаем все збс
    next if mdstatus == plugin[states][device].to_s # disabled in config
    event(:service => "mdadm #{device}", :state => 'critical', :desc => "mdadm failed device #{device}: #{get_failed_parts(device)}")
  end

end
