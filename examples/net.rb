interval 60
always_start true

default[:include_alias] = false
default[:filter] = ['rx bytes', 'rx errs', 'rx drop', 'tx bytes', 'tx errs', 'tx drop']
default[:words] = ['rx bytes', 'rx packets', 'rx errs', 'rx drop', 'rx fifo', 'rx frame',
                   'rx compressed', 'rx multicast', 'tx bytes', 'tx packets', 'tx drops',
                   'tx fifo', 'tx colls', 'tx carrier', 'tx compressed']

collect :os => 'linux' do
  File.read('/proc/net/dev').each_line do |line|
    iface = line.split(':')[0].strip
    iface.gsub!(/\./, '_')
    next if (iface =~ /\./ && !plugin.include_alias)
    next unless line =~ /(\w*)\:\s*([\s\d]+)\s*/
    plugin.words.map do |service|
      service
    end.zip(
        $2.split(/\s+/).map { |str| str.to_i }
    ).each do |service, value|
      next unless plugin.filter.include? service
      event(:service => "net #{iface} #{service}", :metric => value.to_f/interval, :diff => true)
    end
  end
end
