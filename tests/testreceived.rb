class TestReceived

  def initialize(events, file)
    @events = events
    @file = file
  end

  def data
    @data ||= YAML.load_file(@file)
  end

  def compare!

    @events.each do |e|
      data["events"].each do |d|
        next unless d[:service] == e[:service]
        next if d[:result] == e[:state]
        next if d[:time] && d[:time] != e[:time]
        raise "Recieved state: #{e[:state].inspect}, data state: #{d[:result].inspect}. \n Data: #{d.inspect} \n Event: #{e.inspect}"
      end
    end

    from_data = data["events"].select {|x| x[:miss_count] != true }.count
    from_events = @events.count

    raise "Not all events recieved: from data: #{from_data} and from server: #{from_events}" unless 3 * from_data == from_events # see config.yml (3 copy of sample plugin run)

    puts "Recieved events:"
    puts "#{@events.inspect}"
    puts "Sample data:"
    puts "#{data.inspect}"

    puts "All done!"
  end

end
