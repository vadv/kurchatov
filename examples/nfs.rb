interval 60
default[:file] = '/tmp/file'

collect do
  event(
    :state => system("test -f #{file.file}"),
    :desc => "Check file #{file.file}"
  )
end
