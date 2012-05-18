class Desire

  # Mixin provides transactional methods to composite classes, in hopes
  # of making it harder to accidentally use the wrong client instance.
  # Assumes the including class has defined #client.
  module Transaction

    def multi(&block)
      # TODO: support separate multi and exec commands.
      client.multi(&block)
    end

    def discard
      client.discard
    end

    def watch(native)
      client.watch(native.key)
    end

    def unwatch
      client.unwatch
    end

  end

end
