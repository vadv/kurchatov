interval 60
always_start true

collect :os => 'linux' do
  m = File.read('/proc/meminfo').split(/\n/).inject({}) do |info, line|
    x = line.split(/:?\s+/)
    info[x[0]] = x[1].to_i
    info
  end

  free = m['MemFree'].to_i * 1024
  cached = m['Cached'].to_i * 1024
  buffers = m['Buffers'].to_i * 1024
  total = m['MemTotal'].to_i * 1024
  used = total - free
  free_bc = free + buffers + cached
  fraction = 1 - (free_bc.to_f / total)
  swap_fraction = m['SwapTotal'] == 0 ? 0 : 1 - m['SwapFree'].to_f/m['SwapTotal']

  event(:service => 'memory % free', :desc => 'Memory usage, %', :metric => fraction.round(2) * 100, :critical => 85, :warning => 75)
  event(:service => 'memory % swap', :desc => 'Swap usage, %', :metric => swap_fraction.round(2) * 100, :critical => 85, :warning => 75)
  event(:service => 'memory abs free', :desc => 'Memory free (kB)', :metric => free, :state => 'ok')
  event(:service => 'memory abs total', :desc => 'Memory total (kB)', :metric => total, :state => 'ok')
  event(:service => 'memory abs cached', :desc => 'Memory usage, cached (kB)', :metric => cached, :state => 'ok')
  event(:service => 'memory abs buffers', :desc => 'Memory usage, buffers (kB)', :metric => buffers, :state => 'ok')
  event(:service => 'memory abs used', :desc => 'Memory usage, used (kB)', :metric => used, :state => 'ok')
  event(:service => 'memory abs free_bc', :desc => 'Memory usage with cache and buffers (kB)', :metric => free_bc, :state => 'ok')
end

collect :platform => 'windows' do
  memories = WMI::Win32_OperatingSystem.find(:all)
  memories.each do |memory|
    mem_info = {}
    memory.properties_.each do |p|
      mem_info[p.name.wmi_underscore.to_sym] = memory.send(p.name)
    end
    event(
      :service => "memory usage",
      :metric => 100 * (1 - (mem_info[:free_physical_memory].to_f / mem_info[:total_visible_memory_size].to_f)),
      :desc => "Использование памяти",
      :warning => 75,
      :critical => 80
    )
  end
end
