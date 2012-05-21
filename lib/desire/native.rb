class Desire

  # Base class for wrappers representing the native Redis types.
  class Native
    include Desire::Key

    # @!macro [attach] redis_command
    #   @method $1(*args, &block)
    def self.redis_command(name, options={})
      # Redis commands (for all types but strings) are prefixed with
      # a single character representing the type.  We provide method 
      # aliases lacking those prefixes for convenience.
      name = name.to_s
      if options[:alias] == false
        extra = ""
      else
        command_alias = name.slice(1..-1)
        extra = "alias_method :#{command_alias}, :#{name}"
      end
      class_eval <<-EVAL, __FILE__, __LINE__ + 1
        def #{name}(*args, &block)
          if @prepare
            @prepared_commands << [:#{name}, key, *args]
          else
            client.#{name}(key, *args, &block)
          end
        end
        #{extra}
      EVAL

    end

    def prepare(&block)
      # NOT THREADSAFE
      @prepare = true
      yield
      @prepare = false
    end

    def execute_prepared
      @prepared_commands.each do |command|
        client.send(*command)
      end
      @prepared_commands.clear
    end

    attr_reader :client

    # @param [Redis] client
    # @param [String] key The key at which Redis commands will operate.
    def initialize(client, key)
      @client = client
      @key = key
      @prepared_commands = []
    end

  end
end
