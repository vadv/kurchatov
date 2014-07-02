name "plugin with error count"

ignore_errors 4
always_start true

collect do
  raise "error"
end
