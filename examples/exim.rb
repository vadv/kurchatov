always_start true
interval 60
default[:exim] = '/usr/sbin/exim'

run_if do
  File.exists? plugin.exim
end

collect do
  event(:service     => 'exim', :metric => shell(plugin.exim, ' -bpc').to_i,
        :desc => 'Exim: count frozen mails', :warning => 5, :critical => 20)
end
