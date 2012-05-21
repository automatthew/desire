class Desire
  module V0

    # Manages a collection of Redis data structures, generating the key names
    # based on the month, day, or hour of the Time supplied to #get.
    class TimeSlicer
      include Composite

      attr_reader :format_string

      # @param [Redis] client
      # @param [Desire::Native, Desire::Composite] klass
      # @param [:month, :day, :hour] duration
      def initialize(client, klass, base_key, duration=:day)
        @base_key = base_key
        @client = client
        @collector = Collector.new(client, base_key) do |subkey|
          klass.new(@client, subkey)
        end
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

      # @param [Time] time
      # @return [Desire::Native, Desire::Composite] the wrapper instance
      #   for the key corresponding to the input time.
      def get(time)
        time_string = time.strftime(@format_string)
        @collector.get(time_string)
      end

      # @return [Array] all keys managed by the TimeSlice
      def keys
        @collector.keys
      end

      # Create a Unionator for the given range of time slices.
      # Presumes that the TimeSlicer's collection class is SortedSet.
      # @param [Date..Date, Time..Time] range a range of dates or times
      # @return [Unionator]
      def unionator(range)
        Unionator.new(self, range)
      end


      class Unionator
        include Desire::Key

        attr_reader :client

        # @param [TimeSlicer] slicer
        # @param [Range] range a range of dates or times.
        def initialize(slicer, range)
          @slicer = slicer
          @client = @slicer.client
          @range = range
          @aggregates_key = "#{@slicer.base_key}.aggregates"
          @key = "#{@slicer.base_key}#{range_string}"
          @zset = Native::SortedSet.new(@slicer.client, @key)
        end

        # Relay calls intended for the underlying sorted set, but only
        # after making sure the data has been aggregated.
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
          @range.map { |date| date.strftime("#{@slicer.base_key}.#{@slicer.format_string}") }
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
            @member_size = @zset.unionstore(input_keys)
            client.sadd(@aggregates_key, @key)
          end
        end

      end

    end

  end
end
