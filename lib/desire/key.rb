class Desire

  # Mixin for use with any class representing a single Redis type.
  # Provides the Redis methods that work on all keys.
  # Assumes that #client and #key are defined.
  module Key

    attr_reader :key

    def exists?
      client.exists(key)
    end

    def del
      client.del(key)
    end

    def expire(seconds)
      client.expire(key, seconds)
    end

    def expire_at(timestamp)
      client.expireat(key, timestamp)
    end

    def persist
      client.persist(key)
    end

    def ttl
      client.ttl(key)
    end

    def type
      client.type(key)
    end

  end

end
