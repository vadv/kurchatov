name "with error plugin"

ignore_errors true
always_start true

collect do
  raise "error"
end
