class Desire

  # Mixin provides transactional methods to composite classes, in hopes
  # of making it harder to accidentally use the wrong client instance.
  # Assumes the including class has defined #client.
  module Composite

    def multi(&block)
      client.multi(&block)
    end

    def watch(native)
      client.watch(native.key)
    end

  end

end
