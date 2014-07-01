module Kurchatov
  module Mixin
    module Event

      include Kurchatov::Mixin::Queue

      EVENT_FIELDS = [
        :time, :state, :service, :host,
        :description, :tags, :ttl, :metric
      ]

      def event(hash = {})
        @normilize = normalize_event(hash)
        return unless @normilize
        Log.info("Mock message for test plugin: #{hash.inspect}") if Kurchatov::Config[:test_plugin]
        events << hash
      end

      protected

      def normalize_event(hash = {})

        hash[:description] = hash[:desc] if hash[:description].nil? && hash[:desc]
        hash[:metric] = hash[:metric].to_f if hash[:metric].kind_of?(String)
        if hash[:metric].kind_of?(Float)
          hash[:metric] = 0.0 if hash[:metric].nan?
          hash[:metric] = ((hash[:metric] * 100).round/100.to_f) # 1.8.7 round
        end

        set_diff_metric(hash)
        set_bool_metric(hash)
        set_bool_state(hash)
        set_avg_metric(hash)
        set_event_state(hash)

        return false if hash[:miss]

        hash.each { |k, _| hash.delete(k) unless EVENT_FIELDS.include?(k) }
        hash[:service] ||= name
        hash[:tags] ||= Kurchatov::Config[:tags]
        hash[:host] ||= Kurchatov::Config[:host]
        true
      end

      def set_event_state(hash = {})
        return if hash[:state]
        return if hash[:critical].nil? && hash[:warning].nil?
        return if hash[:metric].nil?
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
          hash[:miss] = true
        end
      end

      def set_bool_metric(hash ={})
        hash[:metric] = 0 if hash[:metric] == false
        hash[:metric] = 1 if hash[:metric] == true
      end

      def set_bool_state(hash ={})
        if hash[:state] == true || hash[:state] == false
          hash[:state] = hash[:state] ? 'ok' : 'critical'
        end
      end

      def set_avg_metric(hash ={})

        return if hash[:avg].nil? || hash[:avg].to_i != hash[:avg]
        return if hash[:service].nil?
        return if hash[:metric].nil?

        @history_avg ||= {}
        @history_avg[hash[:service]] ||= []
        @history_avg[hash[:service]] << hash[:metric].to_f
        @history_avg[hash[:service]] = @history_avg[hash[:service]].last(hash[:avg])

        return if hash[:miss]

        if @history_avg[hash[:service]].count >= (hash[:avg] / 2) + 1
          hash[:metric] = @history_avg[hash[:service]].reduce(:+).to_f / @history_avg[hash[:service]].count
        else
          hash[:miss] = true
        end

      end

    end
  end
end
