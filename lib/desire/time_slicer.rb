class Desire

  class TimeSlicer

    attr_reader :client, :key, :format_string
    def initialize(client, klass, base_key, duration=:day)
      @key = base_key
      @client = client
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

    def unionator(range)
      Unionator.new(self, range)
    end

    class Unionator

      attr_reader :client
      def initialize(slicer, range)
        @slicer = slicer
        @client = @slicer.client
        @range = range
        @aggregates_key = "#{@slicer.key}.aggregates"
        @union_key = "#{@slicer.key}#{range_string}"
        @zset = SortedSet.new(@slicer.client, @union_key)
      end

      def method_missing(name, *args, &block)
        if @zset.respond_to?(name)
          self.retrieve
          @zset.send(name, *args, &block)
        else
          super
        end
      end

      def range_string
        "[#{@range.first}..#{@range.last}]"
      end

      def input_keys
        @input_keys ||= @slicer.keys & key_range
      end

      def key_range
        @range.map { |date| date.strftime("#{@slicer.key}.#{@slicer.format_string}") }
      end

      def retrieve
        if @range.include?(Date.today) || !@zset.exists?
          compute!
        else
          @member_size = @zset.card
        end
      end

      def compute!
        if input_keys.empty?
          @member_size = 0
        else
          @member_size = @zset.union!(input_keys)
          client.sadd(@aggregates_key, @union_key)
        end
      end

    end

  end

end
