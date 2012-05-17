class Desire
  class Native
    class Hash < Native
      include Enumerable

      # These commands are defined as instance methods.  Where it is
      # unambiguous, you can omit the initial "h".
      COMMANDS = %w[
        hexists hget hgetall hincrby hincrbyfloat hkeys hlen hmget
        hmset hset hsetnx hvals
      ]

      # NOTE: this has to be evaluated in this exact file so the class_eval
      # call can pick up the correct file and line number for stack traces.
      COMMANDS.each do |command|
        class_eval(self.definition(command), __FILE__, __LINE__ + 1)
      end

      # Remove the value at the given field.
      def hdel(field)
        # Can't automagic this one up, because the magic would overwrite DEL"
        client.hdel(key, field)
      end

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
