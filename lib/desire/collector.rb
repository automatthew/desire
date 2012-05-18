class Desire
  class Collector
    include Enumerable
    include Composite

    attr_reader :index_key, :collection_class

    # @param [Redis] client
    # @param [Desire::Native, Desire::Composite] collection_class the Desire wrapper
    #   class to use when initializing instances for collected items.
    def initialize(client, collection_class, base_key)
      @client = client
      @collection_class = collection_class
      @base_key = base_key
      @index_key = "#{@base_key}.index"
      @index = Native::Set.new(client, @index_key)
    end

    def add(name)
      @client.sadd(@index_key, key_for(name))
    end

    def keys
      @client.smembers(@index_key)
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
      collection_class.new(@client, key_for(name))
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
        yield [key, collection_class.new(@client, key)]
      end
    end

  end
end
