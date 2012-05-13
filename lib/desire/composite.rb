class Desire

  # Assumes the including class has defined #client
  module Composite
    def multi(&block)
      client.multi(&block)
    end
  end

end
