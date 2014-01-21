collect do
  event(
    :metric => File.read('/proc/sys/fs/file-nr').split(' ').first.to_i, 
    :description => "Number of allocated file handles" 
  )
end
