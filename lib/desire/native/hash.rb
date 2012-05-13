class Desire
  class Hash
    include Desire::Key
    include Enumerable

    attr_reader :client, :key

    def initialize(client, key)
      @client = client
      @key = key
    end

    alias_method :clear, :del

    def keys
      client.hkeys(key)
    end

    def get(field)
      client.hget(key, field)
    end

    def set(field, value)
      client.hset(key, field, value)
    end

    def delete(field)
      client.hdel(key, field)
    end

    def size
      client.hlen(key)
    end

    def incrby(field, value)
      client.hincrby(key, field, value)
    end

    def merge!(hash)
      args = hash.to_a.flatten
      client.hmset(key, *args)
    end

    def each(&block)
      client.hgetall(key).each(&block)
    end

    def values_at(*fields)
      client.hmget(key, *fields)
    end

    def getall
      client.hgetall(key)
    end

  end
end
