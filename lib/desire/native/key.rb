class Desire

  # This mixin assumes that #client and #key are defined.
  module Key

    def watch
      client.watch(key)
    end

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
