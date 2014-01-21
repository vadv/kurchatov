interval 60

warning 5

default[:file_mask] = '.*'
default[:dir] = '/tmp/dir'
default[:age] = 24 * 60 * 60

collect do
  if File.directory?(plugin.dir)
    count_files = 0
    file_mask   = Regexp.new(plugin.file_mask)
    Find.find(plugin.dir).each do |file|
      next unless File.file? file
      next unless file_mask.match file
      next unless Time.now.to_i - plugin.age > File.new(file).mtime.to_i
      count_files += 1
    end
    event(:service => "find files #{plugin.dir}", :metric => count_files, :description => "Count files in #{plugin.dir}")
  end
end
