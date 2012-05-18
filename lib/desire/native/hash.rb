class Desire
  class Native

    # A wrapper around the native Redis hash type. 
    #
    #   hash = Desire::Native::Hash.new(redis, "some_hash")
    #   hash.hlen # => 23
    #   hash.len # => 23
    #   hash.size # => 23
    #
    class Hash < Native
      include Enumerable

      redis_command :hdel, :alias => false
      redis_command :hexists
      redis_command :hget
      redis_command :hgetall
      redis_command :hincrby
      redis_command :hincrbyfloat
      redis_command :hkeys
      redis_command :hlen
      redis_command :hmget
      redis_command :hmset
      redis_command :hset
      redis_command :hsetnx
      redis_command :hvals

      # Aliases for idiomaticity
      alias_method :clear, :del
      alias_method :delete, :hdel
      alias_method :[], :hget
      alias_method :[]=, :hset
      alias_method :size, :hlen
      alias_method :values, :hvals
      alias_method :values_at, :hmget
      alias_method :has_key?, :hexists


      # Augmentations

      # HMSET the values in the given hash.
      def merge!(hash)
        args = hash.to_a.flatten
        client.hmset(key, *args)
      end

      # Yield each key,value pair in the Hash
      def each(&block)
        client.hgetall(key).each(&block)
        # TODO: consider adding buffering for large hashes.
        #   pseudocode:
        #   if hlen > N
        #     keys = hkeys
        #     keys.each_slice(M) { |keyslice| hmget(keyslice) }
        #   else
        #     hgetall
        #   end
        #
        # Or make an #each_slice method?
      end

    end
  end
end
