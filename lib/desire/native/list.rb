class Desire
  class Native

  # A wrapper around the native Redis list type. 
    class List < Native

      attr_reader :client, :key

      def initialize(client, key)
        @client = client
        @key = key
      end

      redis_command :lindex
      redis_command :linsert
      redis_command :llen
      redis_command :lpop
      redis_command :lpush
      redis_command :lpushx
      redis_command :lrange
      redis_command :lrem
      redis_command :lset
      redis_command :ltrim
      redis_command :rpop
      redis_command :rpoplpush
      redis_command :rpush
      redis_command :rpushx


      # Aliases for idiomaticity
      alias_method :size, :llen
      alias_method :[], :lindex
      alias_method :[]=, :lset

      #TODO: define methods for slice, slice!, shift, unshift, push, pop
      # TODO: define each and include Enumerable

    end
  end
end
