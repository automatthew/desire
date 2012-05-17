class Desire

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
