name "not ignore errors"

always_start true
ignore_errors false

collect do
  @first_start ||= true
  if @first_start
    raise "error"
  end
  @first_start = false
end
