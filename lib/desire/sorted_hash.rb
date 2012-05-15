class Desire

  class SortedHash
    include Composite

    attr_reader :client, :hash_key, :index_key

    def initialize(client, key, options={})
      @client = client
      @hash_key = "#{key}.store"
      @hash = Desire::Hash.new(client, @hash_key)
      @index_key = "#{key}.index"
      @index = Desire::SortedSet.new(client, @index_key)
      @retry_limit = options[:retries] || 16
      @size_limit = options[:size_limit]
      @ttl = options[:ttl]
    end

    def set(key, value, score)
      multi do
        @hash.set(key, value)
        @index.add(score, key)
      end
    end

    def update(key, value)
      if @hash.has_key?(key)
        @hash.set(key, value)
      else
        raise ArgumentError, "Cannot update nonexistent key: #{key}"
      end
    end

    ## TODO: see if all the score-getting-and-locking
    ## can be encapsulated in the SortedSet class.

    # Uses optimistic locking to make sure the value is
    # added with a score higher than any previously added.
    # It returns the score actually used to set the value.
    def append(key, value, score)
      # attempt the transaction, retrying a limited number of
      # times if the WATCH makes us bail.
      retry_counter = 0
      while retry_counter < @retry_limit
        # Have to put the watch inside the retry loop because
        # calling EXEC clears all watches.
        # TODO: maybe we want to have Composite#watch(@index) ??
        @index.watch

        # get highest score from the Sorted Set and increment the
        # input score if necessary.
        _value, high_score = @index.last(:with_scores => true)
        if high_score
          if score <= high_score.to_i
            score = high_score.to_i + 1
          end
        end

        if set(key, value, score)
          if @size_limit && (@size_limit > 0) && (self.size > @size_limit)
            self.truncate(@size_limit)
          end

          return score
        else
          retry_counter += 1
        end

      end

      raise "Optimistic locking failed too many times"
    end

    alias_method :<<, :append

    def get(key)
      @hash.get(key)
    end

    def get_with_score(key)
      if data = @hash.get(key)
        {:data => data, :score => @index.score(key)}
      end
    end

    def delete(*keys)
      multi do
        keys.each do |k|
          @hash.delete(k)
          @index.delete(k)
        end
      end
      nil
    end

    def remove_by_range(start=nil, stop=nil)
      if !start and !stop
        throw "Must specify either start or stop"
      end

      start = start ? "(#{start}" : '-inf'
      stop = stop ? "#{stop}" : "+inf"

      # Get the keys to delete from the hash
      keys = @index.range_by_score(start, stop)
      # Remove the keys from the index
      @index.delete_by_score(start, stop)
      # Remove the values from the hash
      multi do
        keys.each do |key|
          @hash.delete(key)
        end
      end

      self
    end

    def remove_before(time)
      remove_by_range(nil, time)
    end

    def truncate(length)
      range_stop = -1 - length
      # Get the keys to delete from the hash
      keys = @index.range(0, range_stop)
      # Remove the keys from the index
      @index.delete_by_rank(0, range_stop)

      # Remove the values from the hash
      multi do
        keys.each do |key|
          @hash.delete(key)
        end
      end
      self
    end

    def size
      @hash.size
    end

    def keys
      @index.range(0, -1)
    end

    def clear
      @hash.clear
      @index.clear
    end

    def values_by_range(start=nil, stop=nil, limit=nil, reverse=false)
      keys_and_scores = fields_by_range(start, stop, limit, reverse)
      if keys_and_scores.size > 0
        keys, scores = [], []
        keys_and_scores.each_slice(2) {|key, score| keys << key; scores << score }
        values = values_at(*keys)
        values.zip(scores)
      else
        []
      end
    end

    def values_at(*keys)
      @hash.values_at(*keys)
    end

    def fields_by_range(start=nil, stop=nil, limit=nil, reverse=false)
      start = start ? "(#{start}" : '-inf'
      stop = stop ? "#{stop}" : "+inf"
      options = limit ? {:limit => [0, limit]} : {}
      options[:withscores] = true
      options[:reverse] = reverse
      @index.range_by_score(start, stop, options)
    end

    def consistency_check
      # TODO: something to verify that the ZSET and HASH are in sync
    end

  end
end

