class Desire

  class Set < Native
    include Enumerable

    COMMANDS = %w[
      sadd scard sdiff sdiffstore sinter sinterstore sismember smembers
      smove spop srandmember srem sunion sunionstore
    ]

    # NOTE: this has to be evaluated in this exact file so the class_eval
    # call can pick up the correct file and line number for stack traces.
    COMMANDS.each do |command|
      class_eval(self.definition(command), __FILE__, __LINE__ + 1)
    end

    # Aliases for idiomaticity
    alias_method :clear, :del
    alias_method :<<, :sadd
    alias_method :size, :scard
    alias_method :to_a, :smembers
    alias_method :include?, :sismember
    alias_method :delete, :srem

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

