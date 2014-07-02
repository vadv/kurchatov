name "plugin sleep"

always_start true

collect do
  20.times {|x| puts "Sleep from 'plugin sleep', count: #{x}"; sleep 1; }
  exit 0
end
