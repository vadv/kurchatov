name "cpu"
always_start true
interval 60

default[:per_process] = false

collect :os => 'linux' do
  @old_cpu ||= {}
  File.read('/proc/stat').each_line do |cpu_line|
    cpu_number = cpu_line.scan(/cpu(\d+|\s)\s+/)
    next if cpu_number.empty?
    cpu_number = cpu_number[0][0] == ' ' ? '_total' : cpu_number[0][0]
    cpu_line[/cpu(\d+|\s)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/]
    _, u2, n2, s2, i2 = [$1, $2, $3, $4, $5].map { |e| e.to_i }
    unless @old_cpu[cpu_number].nil?
      u1, n1, s1, i1 = @old_cpu[cpu_number]
      used = (u2+n2+s2) - (u1+n1+s1)
      total = used + i2-i1
      fraction = used.to_f / total
    end
    @old_cpu[cpu_number] = [u2, n2, s2, i2]
    service = "cpu usage cpu#{cpu_number}"
    description = "Cpu#{cpu_number} usage"
    if cpu_number == '_total'
      event(:service => service, :metric => fraction, :desc => description, :warning => 70, :critical => 58)
    else
      event(:service => service, :metric => fraction, :desc => description, :state => 'ok')
    end
  end
end

collect :platform => 'windows' do
  perfs = WMI::Win32_PerfFormattedData_Counters_ProcessorInformation.find(:all)
  perfs.each do |perf|

    perf_info = {}
    perf.properties_.each do |p|
      perf_info[p.name.wmi_underscore.to_sym] = perf.send(p.name)
    end

    human_name = perf_info[:name].gsub(",", ":").gsub("_","").gsub("Total","(общее)").downcase
    event(
      :service => "cpu usage #{perf_info[:name]}",
      :metric => perf_info[:percent_processor_time].to_f,
      :desc => "Использование процессора #{human_name}",
      :warning => 75,
      :critical => 80
    )
  end
end
