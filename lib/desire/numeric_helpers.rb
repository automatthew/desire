class Desire

  module NumericHelpers

    def to_number(string)
      begin
        Integer(string)
      rescue ArgumentError
        Float(string)
      end
    end

  end
end
