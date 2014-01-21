module Kurchatov
  module Mixin
    module Event

      EVENT_FIELDS = [
        :time, :state, :service, :host,
        :description, :tags, :ttl, :metric
      ]

      def event(hash = {})
        normilize_event(hash)
        Log.info("Mock message for test plugin: #{hash.inspect}") if Kurchatov::Config[:test_plugin]
        events << hash
      end

      protected

      def normilize_event(hash = {})
        hash[:description] = hash[:desc] if hash[:description].nil? && hash[:desc]
        if hash[:metric].kind_of?(Float)
          hash[:metric] = 0.0 if hash[:metric].nan?
          hash[:metric] = hash[:metric].round(2)
        end
        set_diff_metric(hash)
        set_event_state(hash)
        hash.each {|k,_| hash.delete(k) unless EVENT_FIELDS.include?(k)}
        hash[:service] ||= name
        hash[:tags] ||= Kurchatov::Config[:tags]
        hash[:host] ||= Kurchatov::Config[:host]
      end

      def set_event_state(hash = {})
        return if hash[:state]
        return if hash[:critical].nil? && hash[:warning].nil?
        return if hash[:metric].nil?
        if hash[:state] == true || hash[:state] == false
          hash[:state] = hash[:state] ? 'ok' : 'critical'
          return
        end
        hash[:state] = 'ok'
        hash[:state] = 'warning' if hash[:warning] && hash[:metric] >= hash[:warning]
        hash[:state] = 'critical' if hash[:critical] && hash[:metric] >= hash[:critical]
      end

      def set_diff_metric(hash ={})
        hash[:diff] ||= hash[:as_diff] if hash[:as_diff]
        return if hash[:diff].nil? && !hash[:diff]
        return if hash[:metric].nil?
        return if hash[:service].nil?
        @history ||= {}
        if @history[hash[:service]]
          old_metric = @history[hash[:service]]
          @history[hash[:service]] = hash[:metric]
          hash[:metric] = hash[:metric] - old_metric
        else
          @history[hash[:service]] = hash[:metric]
          hash[:metric] = nil
        end
      end

    end
  end
end
