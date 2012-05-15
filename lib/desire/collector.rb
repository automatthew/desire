class Desire
  class Collector
    include Enumerable

    attr_reader :base_key, :index_key, :klass
    def initialize(client, klass, base_key)
      @client = client
      @klass = klass
      @base_key = base_key
      @index_key = "#{@base_key}.index"
      @index = Desire::Set.new(client, @index_key)
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
      klass.new(@client, key_for(name))
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
        yield [key, klass.new(@client, key)]
      end
    end

  end
end
