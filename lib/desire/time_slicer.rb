class Desire

  class TimeSlicer

    def initialize(client, klass, base_key, duration=:day)
      @collector = Collector.new(client, klass, base_key)
      case duration
      when :month
        @format_string = '%Y-%m'
      when :day
        @format_string = '%Y-%m-%d'
      when :hour
        @format_string = '%Y-%m-%dT%H'
      else
        raise ArgumentError, "Unsupported duration: #{duration}"
      end
    end

    def get(time)
      time_string = time.strftime(@format_string)
      @collector.get(time_string)
    end

    def keys
      @collector.keys
    end


  end

end
