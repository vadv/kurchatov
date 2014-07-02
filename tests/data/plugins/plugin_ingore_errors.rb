name "ignore errors"

always_start true
ignore_errors true
interval 1

collect do
  raise "error"
end
