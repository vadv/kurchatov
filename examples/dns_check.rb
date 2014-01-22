collect do
  event(
      :state => Resolv::DNS.new.getresources(ohai[:fqdn], Resolv::DNS::Resource::IN::A).count == 1,
      :desc => 'Check resolv self FQDN')
end
