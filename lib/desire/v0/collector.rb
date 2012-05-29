class Desire
  module V0

    class Collector
      # TODO implement #remove
      include Enumerable
      include Composite

      attr_reader :index_key

      # @param [Redis] client
      def initialize(client, base_key, &block)
        raise ArgumentError unless block
        @client = client
        @block = block
        @base_key = base_key
        @index_key = "#{@base_key}.index"
        @index = Native::Set.new(client, @index_key)
      end

      def add(name)
        @index.sadd(key_for(name))
      end

      def keys
        @index.smembers
      end

      def key_for(name)
        "#{@base_key}.#{name}"
      end

      def name_for(key)
        x = @base_key.size + 1
        key.slice(x..-1)
      end

      def get(name)
        add(name)
        instantiate(name)
      end

      def instantiate(name)
        @block.call(key_for(name))
      end

      def all
        out = {}
        each do |key, instance|
          name = name_for(key)
          out[name] = instance
        end
        out
      end

      def each
        keys.each do |key|
          yield [key, instantiate(key)]
        end
      end

    end
  end
end
