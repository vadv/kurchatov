name "disk"
always_start true

collect :platform => 'windows' do
  disks = WMI::Win32_LogicalDisk.find(:all)
  disks.each do |disk|
    ld_info = {}
    disk.properties_.each do |p|
      ld_info[p.name.wmi_underscore.to_sym] = disk.send(p.name)
    end
    event(
      :service => "disk usage #{ld_info[:name]} #{ld_info[:volume_name]}",
      :metric => 100 * (1 - ld_info[:free_space].to_f / ld_info[:size].to_f),
      :desc => "Использование диска #{ld_info[:name]} (#{ld_info[:volume_name]})",
      :warning => 75,
      :critical => 80
    )
  end
end
