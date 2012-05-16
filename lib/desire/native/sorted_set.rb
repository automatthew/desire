class Desire

  class SortedSet
    include Desire::Key
    include Desire::NumericHelpers
    include Enumerable

    attr_reader :client, :key

    def initialize(client, key)
      @client = client
      @key = key
    end

    def union!(input_keys, options={})
      client.zunionstore(key, input_keys, options)
    end

    def inter!(input_keys, options={})
      client.zinterstore(key, input_keys, options)
    end

    def members
      client.zrange(key, 0, -1)
    end

    def card
      client.zcard(key)
    end

    alias_method :size, :card

    def scores
      out = []
      array = self.range(0, -1, :withscores => true)
      array.each_slice(2) {|account_key, value| out << to_number(value) }
      out
    end

    def to_hash
      array = self.range(0, -1, :withscores => true)
      ::Hash[*array]
    end

    def add(score, value)
      client.zadd(key, score, value)
    end

    def delete(member)
      client.zrem(key, member)
    end

    def clear
      del
    end

    # TODO: do we really want to be renaming redis commands
    # if the new name is not an established Ruby idiom?
    def delete_by_score(start, stop)
      client.zremrangebyscore(key, start, stop)
    end

    def delete_by_rank(start, stop)
      client.zremrangebyrank(key, start, stop)
    end

    def range_by_score(start, stop, options={})
      if options.has_key?(:reverse)
        options.delete(:reverse)
        client.zrevrangebyscore(key, stop, start, options)
      else
        client.zrangebyscore(key, start, stop, options)
      end
    end

    def range(start, stop, options={})
      client.zrange(key, start, stop, options)
    end

    ## TODO: imitate Array#slice
    #def slice(*args)
    #end

    def score(member)
      client.zscore(key, member)
    end

    def count(start, stop)
      client.zcount(key, start, stop)
    end

    def incrby(increment, value)
      client.zincrby(key, increment, value)
    end

    def multi_incrby(properties)
      properties.each do |name, value|
        self.incrby(value, name)
      end
    end

    def last(options={})
      client.zrange(key, -1, -1, options)
    end

  end
end
