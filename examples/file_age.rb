default[:file] = '/notexists'

collect do
  event(
      :service => "#{name} #{plugin.file}",
      :metric => (unixnow - File.stat(plugin.file).mtime.to_i).abs.to_f/60,
      :description => "File #{plugin.file} age",
      :warning => 1,
      :critical => 5
  )
end
