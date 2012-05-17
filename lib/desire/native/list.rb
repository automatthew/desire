class Desire
  class List < Native
    # TODO: define each and include Enumerable
    #include Enumerable

    attr_reader :client, :key

    def initialize(client, key)
      @client = client
      @key = key
    end

    COMMANDS = %w[
      lindex linsert llen lpop lpush lpushx
      lrange lrem lset ltrim rpop rpoplpush rpush rpushx
    ]

    # NOTE: this has to be evaluated in this exact file so the class_eval
    # call can pick up the correct file and line number for stack traces.
    COMMANDS.each do |command|
      class_eval(self.definition(command), __FILE__, __LINE__ + 1)
    end

    # Aliases for idiomaticity
    alias_method :size, :llen
    alias_method :[], :lindex
    alias_method :[]=, :lset

    #TODO: define methods for slice, slice!, shift, unshift, push, pop

  end
end
