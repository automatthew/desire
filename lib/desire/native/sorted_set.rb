class Desire

  class SortedSet < Native
    include Desire::NumericHelpers
    include Enumerable

    COMMANDS = %w[
      zadd zcard zcount zincrby zinterstore zrange zrangebyscore
      zrank zrem zremrangebyrank zremrangebyscore zrevrange
      zrevrangebyscore zrevrank zscore zunionstore 
    ]

    # NOTE: this has to be evaluated in this exact file so the class_eval
    # call can pick up the correct file and line number for stack traces.
    COMMANDS.each do |command|
      class_eval(self.definition(command), __FILE__, __LINE__ + 1)
    end

    # Aliases for idiomaticity
    alias_method :size, :zcard
    alias_method :<<, :zadd
    alias_method :delete, :zrem
    alias_method :clear, :del
    alias_method :delete_by_score, :zremrangebyscore
    alias_method :delete_by_rank, :zremrangebyrank



    # Augmentations
    def members
      client.range(key, 0, -1)
    end

    def first(options={})
      client.zrange(key, 0, 0, options)
    end

    def last(options={})
      client.zrange(key, -1, -1, options)
    end

    def scores
      out = []
      array = self.range(0, -1, :withscores => true)
      array.each_slice(2) {|account_key, value| out << to_number(value) }
      out
    end

    # For pretending it's a Ruby Hash with the sorted set members as
    # the keys, and the scores as the values.  Dubious?
    alias_method :keys, :members
    alias_method :values, :scores

    def to_hash
      array = self.range(0, -1, :withscores => true)
      ::Hash[*array]
    end

    # TODO: port improvements by nlacasse from Spire's SortedHash
    def range_by_score(start, stop, options={})
      if options.has_key?(:reverse)
        options.delete(:reverse)
        client.zrevrangebyscore(key, stop, start, options)
      else
        client.zrangebyscore(key, start, stop, options)
      end
    end

    # Takes a Ruby Hash where the keys represent set members, 
    # and the values represent set scores.
    def multi_incrby(properties)
      properties.each do |name, value|
        self.incrby(value, name)
      end
    end

    ## TODO: imitate Array#slice
    #def slice(*args)
    #end

  end
end
