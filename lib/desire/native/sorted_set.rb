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

    def members
      client.zrange(key, 0, -1)
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

    def range(start, stop)
      client.zrange(key, start, stop)
    end

    def score(member)
      client.zscore(key, member)
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
