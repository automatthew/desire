class Desire
  class Native

    class SortedSet < Native
      include Desire::NumericHelpers
      #include Enumerable

      redis_command :zadd
      redis_command :zcard
      redis_command :zcount
      redis_command :zincrby
      redis_command :zinterstore
      redis_command :zrange
      redis_command :zrangebyscore
      redis_command :zrank
      redis_command :zrem
      redis_command :zremrangebyrank
      redis_command :zremrangebyscore
      redis_command :zrevrange
      redis_command :zrevrangebyscore
      redis_command :zrevrank
      redis_command :zscore
      redis_command :zunionstore


      # Aliases for idiomaticity
      alias_method :size, :zcard
      alias_method :<<, :zadd
      alias_method :delete, :zrem
      alias_method :clear, :del
      alias_method :delete_by_score, :zremrangebyscore
      alias_method :delete_by_rank, :zremrangebyrank



      # Augmentations

      # @return [Array] all members
      def members
        client.range(key, 0, -1)
      end

      # @param [Hash] options options to pass to the redis command
      # @return [String] the member with the lowest score
      def first(options={})
        client.zrange(key, 0, 0, options)
      end

      # @param [Hash] options options to pass to the redis command
      # @return [String] the member with the highest score
      def last(options={})
        client.zrange(key, -1, -1, options)
      end

      # @return [Array<Numeric>] all scores
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

      # @return [Hash] a hash with members as keys and scores as values
      def to_hash
        array = self.range(0, -1, :withscores => true)
        ::Hash[*array]
      end

      # @param [Hash] options options to pass to the redis command
      # @return [Array] the Redis multibulk reply
      def range_by_score(start, stop, options={})
      # TODO: port improvements by nlacasse from Spire's SortedHash
        if options.has_key?(:reverse)
          options.delete(:reverse)
          client.zrevrangebyscore(key, stop, start, options)
        else
          client.zrangebyscore(key, start, stop, options)
        end
      end

      # Given a Ruby Hash where the keys represent set members, 
      # and the values represent set scores, performs ZINCRBY on each pair.
      # @param [{key => score}] properties
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
end
