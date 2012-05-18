class Desire
  class Native

    class Set < Native
      include Enumerable

      redis_command :sadd
      redis_command :scard
      redis_command :sdiff
      redis_command :sdiffstore
      redis_command :sinter
      redis_command :sinterstore
      redis_command :sismember
      redis_command :smembers
      redis_command :smove
      redis_command :spop
      redis_command :srandmember
      redis_command :srem
      redis_command :sunion
      redis_command :sunionstore

      # Aliases for idiomaticity
      alias_method :clear, :del
      alias_method :<<, :sadd
      alias_method :size, :scard
      alias_method :to_a, :smembers
      alias_method :include?, :sismember
      alias_method :delete, :srem

      # Yield each member of the set.
      def each(&block)
        to_a.each(&block)
      end

      # TODO: define wrapper methods for {union, intersect, subtract} that
      # detect whether the input arguments are strings (representing redis
      # keys of other Sets), or Ruby instances of this class.
      #def |(*others)
        #@client.sunion(key, *others)
      #end

      #def &(*others)
        #@client.sinter(key, *others)
      #end

    end
  end
end
