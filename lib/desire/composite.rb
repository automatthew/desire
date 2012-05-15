class Desire

  # Assumes the including class has defined #client
  module Composite

    def multi(&block)
      client.multi(&block)
    end

    def watch(native)
      client.watch(native.key)
    end

  end

end
