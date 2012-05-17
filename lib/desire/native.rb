class Desire
  class Native
    include Desire::Key

    def self.definition(command)
      # Redis commands (for all types but strings) are prefixed with
      # a single character representing the type.  We provide method 
      # aliases lacking those prefixes for convenience.
      command_alias = command.slice(1..-1)
      x = <<-EVAL
        def #{command}(*args, &block)
          client.#{command}(key, *args, &block)
        end
        alias_method :#{command_alias}, :#{command}
      EVAL
    end

    attr_reader :client, :key

    def initialize(client, key)
      @client = client
      @key = key
    end

  end
end
