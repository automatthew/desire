class Desire
  class Hash < Native
    include Enumerable

    COMMANDS = %w[
      hdel hexists hget hgetall hincrby hincrbyfloat hkeys hlen hmget
      hmset hset hsetnx hvals
    ]

    # NOTE: this has to be evaluated in this exact file so the class_eval
    # call can pick up the correct file and line number for stack traces.
    COMMANDS.each do |command|
      class_eval(CommandHelpers.definition(command), __FILE__, __LINE__ + 1)
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

    def merge!(hash)
      args = hash.to_a.flatten
      client.hmset(key, *args)
    end

    # TODO: consider adding buffering for large hashes.
    # if hlen > N
    #   keys = hkeys
    #   keys.each_slice(M) { |keyslice| hmget(keyslice) }
    # else
    #   hgetall
    # end
    #
    # Or make an #each_slice method?
    def each(&block)
      client.hgetall(key).each(&block)
    end

  end
end
