class Desire

  module CommandHelpers
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
  end

  module NumericHelpers

    # Given a string representing a number, return an Integer or Float.
    def to_number(string)
      begin
        Integer(string)
      rescue ArgumentError
        Float(string)
      end
    end

  end
end
