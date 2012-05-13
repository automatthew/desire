class Desire
  class Set
    include Enumerable

    attr_reader :client, :key

    def initialize(client, key)
      @client = client
      @key = key
    end

    def each(&block)
      to_a.each(&block)
    end

    def to_a
      @client.smembers(key)
    end

    def size
      @client.scard(key)
    end

    def |(*others)
      @client.sunion(key, *others)
    end

    def &(*others)
      @client.sinter(key, *others)
    end

  end
end

