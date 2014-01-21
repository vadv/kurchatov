always_start true
interval 60

default[:words] = [ 'reads reqs', 'reads merged', 'reads sector', 'reads time',
                     'writes reqs', 'writes merged', 'writes sector', 'writes time',
                     'io reqs', 'io time', 'io weighted' ]

default[:filter] = [ 'reads reqs', 'writes reqs' ] 

run_if do
  File.exists? '/proc/diskstats'
end

collect :os => "linux" do
  f = File.read('/proc/diskstats')
  f.split("\n").reject { |d| d =~ /(ram|loop)/ }.inject({}) do |_, line|
    if line =~ /^(?:\s+\d+){2}\s+([\w\d]+) (.*)$/
      dev    = $1
      values = $2.split(/\s+/).map { |str| str.to_i }
      next if !!(dev.match /\d+$/ || !(dev.match =~ /^xvd/))
      plugin.filter.each do |filter|
        event(:service => "diskstat #{dev} #{filter}", :metric => values[plugin.words.index(filter)].to_f/interval, :diff => true)
      end
      iops = values[plugin.words.index('reads reqs')].to_i + values[plugin.words.index('writes reqs')].to_i
      event(:service => "diskstat #{dev} iops", :metric => iops.to_f/interval, :diff => true)
    end
  end
end
